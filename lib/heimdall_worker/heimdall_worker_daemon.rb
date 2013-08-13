$LOAD_PATH << File.expand_path(File.dirname(__FILE__))
require 'rubygems'
require 'yaml'
require 'daemons'
require 'rubytorrent'

f = File.open( File.dirname(__FILE__) + '/config/worker.yml')
worker_config = YAML.load(f)

ENV['RAILS_ENV'] = worker_config['rails_env']

MASTER_TEST_MAX_COUNTER = 50000
MIN_FREE_SPACE_GB = 10
SLEEP_WAITING_FOR_FREE_SPACE_TIME = 120
SLEEP_WAITING_FOR_LOAD_TO_GO_DOWN = 120
SLEEP_WAITING_FOR_DAEMONS_TO_END = 120
SLEEP_WAITING_BETWEEN_RUNS = 15
SLEEP_WAITING_BETWEEN_CHECK_AZ_DOWNLOAD = 10
SQL_RESET_TIME_SEC = 120

EMAIL_REPORTING_INTERVALS = 86000
SELLERS_DETECTION_THRESHOLD = 1.0
MAX_NUMBER_OF_DEAMONS = 1

require 'rubygems'

require 'sys/filesystem'
include Sys

require 'rss/1.0'
require 'rss/2.0'
require 'open-uri'

require 'amatch'
include Amatch

require File.dirname(__FILE__) + '/../utils/logger.rb'
require File.dirname(__FILE__) + '/../utils/shell.rb'

require 'active_record'
require_gem("actionmailer")

require File.dirname(__FILE__) + '/../../config/boot'
require "#{RAILS_ROOT}/config/environment" 

require File.dirname(__FILE__) + '/../../app/models/admin_mailer.rb'

require 'yaml'

class Array
  def random(weights=nil)
    return random(map {|n| n.send(weights)}) if weights.is_a? Symbol
    weights ||= Array.new(length, 1.0)
    total = weights.inject(0.0) {|t,w| t+w}
    point = rand * total
   
    zip(weights).each do |n,w|
    return n if w >= point
      point -= w
    end
  end
end

class HeimdallWorker
  def initialize(config)
    @logger = Logger.new("/var/log/heimdall_"+ENV['RAILS_ENV']+".log")
    @shell = Shell.new(self)
    @worker_config = config
    @counter = 0
    @last_report_time = 0
  end

  def log_time
    t = Time.now
    "%02d/%02d %02d:%02d:%02d.%06d" % [t.day, t.month, t.hour, t.min, t.sec, t.usec]
  end

  def info(text)
    @logger.info("cs_info %s: %s" % [log_time, text])
  end

  def warn(text)
    @logger.warn("cs_warn %s: %s" % [log_time, text])
  end

  def error(text)
    @logger.error("cs_error %s: %s" % [log_time, text])
    #TODO: SEND ADMIN EMAIL
  end

  def debug(text)
    @logger.debug("cs_debug %s: %s" % [log_time, text])
  end

  def poll_possible_matches
    debug("poll_possible_matches")
    @possible_match = HeimdallPossibleMatch.find(:first, :conditions => "active = 1 AND processing_stage = 'pending'", :lock => true)
    if @possible_match
      @possible_match.processing_stage = "processing"
      @possible_match.download_started_at = Time.now
      @possible_match.save
      info("Checking #{@possible_match.title}")
      @torrent_source_folder = "/var/content/heimdall_#{ENV['RAILS_ENV']}/torrent_sources/#{@possible_match.id}"
      @torrent_folder = "/var/content/heimdall_#{ENV['RAILS_ENV']}/torrents/#{@possible_match.id}"
      @download_folder = "/var/content/heimdall_#{ENV['RAILS_ENV']}/downloads/#{@possible_match.id}"
      @forensic_tests_folder = "/var/content/heimdall_#{ENV['RAILS_ENV']}/forensic_tests/#{@possible_match.id}"
      @torrent_file = "#{@torrent_source_folder}/file.torrent"
      FileUtils.mkpath(@torrent_folder)
      FileUtils.mkpath(@torrent_source_folder)
      FileUtils.mkpath(@download_folder)
      FileUtils.mkpath(@forensic_tests_folder)
      debug(@torrent_file)
      f = File.new(@torrent_file,"w")
      f.write(@possible_match.torrent_file.to_s)
      #debug(@possible_match.torrent_file.inspect)
      f.close
#      f2 = File.new(@torrent_file+"jj","w")
#      f2.write(@possible_match.torrent_file.to_s)
#      f2.close
      command = "LOCALUSER=\"robert\";export LOCALUSER;java -jar /home/robert/work/Azureus/Azureus3.0.3.4.jar  --ui=console"    
  #    torrent = "http://torrent.ibiblio.org/torrents/download/69656ddf6cb102f7a332c73f7cae0a767af81437.torrent"
      torrent = @torrent_file #@possible_match.url
      @state = "starting"
      @start_time = Time.now.to_i
      @set_settings = true
      @shell.execute("rm -r /home/robert/.azureus")
      check_load_and_wait
      az = IO.popen(command, "w+")
      @last_sql_reload_time = Time.now
      loop do
        if @last_sql_reload_time < Time.now - SQL_RESET_TIME_SEC
          @possible_match.reload
          @last_sql_reload_time = Time.now
        end
        line = az.readline
        if @set_settings
          az.puts "set \"update.start\" 0\r\n" 
          az.puts "set \"Auto Upload Speed Enabled\" 1\r\n"
          az.puts "set \"AutoSpeed Max Upload KBs\" 25\r\n"
          az.puts "set \"Core_iMaxUploadSpeed\" 25\r\n"
          az.puts "set \"Core_iMaxUploads\" 3\r\n"
          az.puts "set \"Core_iMaxPeerConnectionsTotal\" 42\r\n"
          az.puts "set \"Core_bDisconnectSeed\" 1\r\n"
          az.puts "set \"Auto Upload Speed Seeding Enabled\" 1\r\n"
          az.puts "set \"update.periodic\" 0"
          az.puts "set \"max.uploads.when.busy.inc.min.secs\" 7\r\n"
          az.puts "set \"Max Download Speed KBs\" 990\r\n"
          az.puts "set \"Max Uploads Seeding\" 1\r\n"
          az.puts "set \"Auto Update\" 0\r\n"
          az.puts "set \"Max Upload Speed Seeding KBs\" 52\r\n"
          az.puts "set \"Max Upload Speed\" 42\r\n"
          az.puts "set \"Max LAN Download Speed KBs\" 990\r\n"
          az.puts "set \"Max LAN Upload Speed KBs\" 42\r\n"
          az.puts "set \"enable.seedingonly.maxuploads\" 1\r\n"
          az.puts "set \"enable.seedingonly.upload.rate\" 5\r\n"
          az.puts "set \"SpeedManagerAlgorithmProviderV2.setting.download.max.limit\" 990\r\n"
          az.puts "set \"SpeedManagerAlgorithmProviderV2.setting.upload.max.limit\" 42\r\n"
          az.puts "set \"Max.Peer.Connections.Per.Torrent.When.Seeding.Enable\" 2\r\n"
          az.puts "set \"Pause Downloads On Exit\" 1\r\n"
          az.puts "set \"General_sDefaultSave_Directory\" #{@download_folder}\r\n"
          az.puts "set \"General_sDefaultTorrent_Directory\" #{@torrent_folder}\r\n"
          @set_settings = false
        end
        info(line.gsub("\n",''))
        if @state == "starting" and line =~ /(off console)/i
          info("Adding torrent")
          az.puts "add #{torrent}\r\n"
          @state = "waiting"
        end
        if @state == "waiting" and (line =~ /(Total Connected Peers)/i or line =~ /(added.)/i)
          az.puts "show t\r\n"
          sleep(SLEEP_WAITING_BETWEEN_CHECK_AZ_DOWNLOAD)
        elsif @state == "waiting" and line =~ /(100.0%)/i and line =~ /(\*)/i
    	  az.puts "quit\r\n"
          break
        end      
        $defout.flush
      end      
      az.close
      @possible_match.reload
      @possible_match.download_completed_at = Time.now
      @possible_match.forensics_start_at = Time.now
      @possible_match.save      
      if @possible_match.multiple_files
        info("Multiple files for folder: #{@download_folder}")
        multi_folder = Dir["#{@download_folder}/*"][0]
        debug("Multiple files folder: #{multi_folder.inspect}")
        files = Dir["#{multi_folder}/*"]
        debug("Multiple files folder: #{files.inspect}")
        for file in files
    	  check_load_and_wait
	      test_wav = "#{@forensic_tests_folder}/#{File.basename(file)}.test.wav"
          @shell.execute("ffmpeg -i \"#{file}\" \"#{test_wav}\"") unless FileTest.exist?(test_wav)
	      check_load_and_wait
          @possible_match.reload
          @shell.execute("pcm-watermark retrieve -i \"#{@forensic_tests_folder}/#{File.basename(file)}.test.wav\" -s /home/robert/work/ContentManagement/mjolnir/tools/watermark/setup_0.txt -RMF #{@forensic_tests_folder}/results.txt -KFILE /home/robert/work/ContentManagement/mjolnir/tools/watermark/key.txt -PCMC0")
          check_load_and_wait
    	  #Parse results
          #Check against database
        end
      else
        info("One file")
        file = Dir['#{@download_folder}/*'][0]
    	check_load_and_wait
    	test_wav = "#{@forensic_tests_folder}/#{File.basename(file)}.test.wav"
    	@shell.execute("ffmpeg -i \"#{file}\" \"#{test_wav}\"") unless FileTest.exist?(test_wav)
    	check_load_and_wait
    	@shell.execute("pcm-watermark retrieve -i #{@forensic_tests_folder}/#{File.basename(download_test_file)}.test.wav -s /home/robert/work/ContentManagement/mjolnir/tools/watermark/setup_0.txt -RMF #{@forensic_tests_folder}/results.txt -KFILE /home/robert/work/ContentManagement/mjolnir/tools/watermark/key.txt -PCMC0")
      end
      @possible_match.reload
      @possible_match.processing_stage = "completed"
      @possible_match.forensics_end_at = Time.now
      @possible_match.active = 0
      @possible_match.save      
    end
  end

  def check_single_torrent_and_create_possible_match(content_target_id, title, url)
    debug("check_single_torrent_and_create_possible_match url:#{url}:")
    #TODO: Add Hash check instead of title check...
    meta = RubyTorrent::MetaInfo.from_location(url)
    unless meta
      error("Bad meta info")
      #email admins
      return
    end
    if meta.info.sha1
      @possible_match = HeimdallPossibleMatch.find_by_sha1(meta.info.sha1, :lock => true)
    elsif meta.info.md5sum
      @possible_match = HeimdallPossibleMatch.find_by_md5sum(meta.info.md5sum, :lock => true)
    else
      error("No checksum in Meta info")
      return
    end
    if @possible_match
      @possible_match.detection_count += 1
      @possible_match.save
      debug("Content: #{title} already found")
    else
      @possible_match = HeimdallPossibleMatch.new
      @possible_match.title = title
      @possible_match.url = url
      @possible_match.heimdall_content_target_id = content_target_id
      @possible_match.sha1 = meta.info.sha1
      @possible_match.torrent_file = meta.to_bencoding
      @possible_match.indicated_file_size = meta.info.total_length
      @possible_match.num_pieces = meta.info.num_pieces
      @possible_match.multiple_files = meta.info.multiple?
      if @content_to_check
        @possible_match.description = @content_to_check.description
        @possible_match.category = @content_to_check.category
        @possible_match.published_date = @content_to_check.pubDate
      end
      @possible_match.first_detected_at = Time.now
      @possible_match.last_detected_at = Time.now
      @possible_match.processing_stage = "pending"
      @possible_match.detection_count = 1      
      @possible_match.active = 1
      @possible_match.save
    end
  end
  
  def process_rss_target
    debug("process_rss_target")
    content = ""
    open(@target.url) do |s| content = s.read end
    @rss_content = RSS::Parser.parse(content, false)
    debug(@rss_content.inspect)

    @content_targets = HeimdallContentTarget.find(:all)
    debug(@content_targets.inspect)
    for content_target in @content_targets
      search_titles = content_target.search_titles.split(',')
      for @content_to_check in @rss_content.items
        normalized_title = @content_to_check.title.downcase.gsub("_", ' ').gsub("-",' ')
        debug("Checking: #{normalized_title}")
        check_content = false
        for search_title in search_titles
          sellers_detection = Sellers.new(search_title.downcase.gsub("_", ' ').gsub("-",' '))
	  sellers_score = sellers_detection.search(normalized_title)
	  debug("Checking: #{search_title} sellers_score: #{sellers_score}")
          if sellers_score <= SELLERS_DETECTION_THRESHOLD
            debug("FOUND")
            check_content = true
          end
        end
        if check_content
          check_single_torrent_and_create_possible_match(content_target.id, @content_to_check.title, @content_to_check.link)
        end
      end
    end    
  end
  
  def poll_for_work
    debug("poll_for_work")
    @target = HeimdallSiteTarget.find(:first, :conditions => "active = 1 AND last_processing_time < NOW() - processing_time_interval", :lock => true)
    if @target
      @target.last_processing_time = Time.now
      @target.save
      if @target.url_type == "rss"
        process_rss_target
      elsif @target.url_type == "single_torrent"
        check_single_torrent_and_create_possible_match(@target.heimdall_content_target_id, @target.title, @target.url)
        @target.reload
        @target.active = false
        @target.save
      end
    else
      poll_possible_matches
    end
  end

  def load_avg
    results = ""
    IO.popen("cat /proc/loadavg") do |pipe|
      pipe.each("\r") do |line|
        results = line
        $defout.flush
      end
    end
    results.split[0..2].map{|e| e.to_f}
  end

  def check_load_and_wait
    loop do
      break if load_avg[0] < @worker_config["max_load_average"]
      info("Load Average #{load_avg[0]}, #{load_avg[1]}, #{load_avg[2]}")      
      info("Load average too high pausing for #{SLEEP_WAITING_FOR_LOAD_TO_GO_DOWN}")
      sleep(SLEEP_WAITING_FOR_LOAD_TO_GO_DOWN)
    end
  end

  def email_progress_report(freeGB)
    info("emailing report")
    begin
      report = AdminMailer.create_report("Heimdall Unit #{@worker_config['video_server_id']} Reporting",
       "Free heimdall space in GB #{freeGB} - Run count: #{@counter}\n\nLoad Average #{load_avg[0]}, #{load_avg[1]}, #{load_avg[2]}")
      report.set_content_type("text/html")
      AdminMailer.deliver(report)
    rescue => ex
      error(ex)
      error(ex.backtrace)
    end
    #TODO: Add time of email
  end

  def run
    info("Starting loop")
    @daemon_count = 0
    @daemons = []
    loop do
      stat = Filesystem.stat("/var/content/heimdall_"+ENV['RAILS_ENV']+"/")
      freeGB = (stat.block_size * stat.blocks_available) /1024 / 1024 / 1024
      if @last_report_time+EMAIL_REPORTING_INTERVALS<Time.now.to_i
        email_progress_report(freeGB) unless ENV['RAILS_ENV']=="development"
        @last_report_time = Time.now.to_i
      end
      info("Free crawling space in GB #{freeGB} - Run count: #{@counter}")
      info("Load Average #{load_avg[0]}, #{load_avg[1]}, #{load_avg[2]}")      
      if load_avg[0] < @worker_config["max_load_average"]
        if freeGB > MIN_FREE_SPACE_GB
          if ENV['RAILS_ENV'] == 'development' && @counter > MASTER_TEST_MAX_COUNTER
            warn("Reached maximum number of test runs - sleeping for an hour")
            sleep(3600)
          else
            @counter = @counter + 1
            begin
              poll_for_work
            rescue => ex
              error("Problem with watermark worker")
              error(ex)
              error(ex.backtrace)
            end
          end
          info("Sleeping for #{SLEEP_WAITING_BETWEEN_RUNS} sec")
          sleep(SLEEP_WAITING_BETWEEN_RUNS)
        else
          info("No more space on disk for cache - sleeping for #{SLEEP_WAITING_FOR_FREE_SPACE_TIME} sec")
          sleep(SLEEP_WAITING_FOR_FREE_SPACE_TIME)
        end
      else
        info("Load average too high at: #{load_avg[0]} - sleeping for #{SLEEP_WAITING_FOR_LOAD_TO_GO_DOWN} sec")
        sleep(SLEEP_WAITING_FOR_LOAD_TO_GO_DOWN)
      end
    end
    puts "THE END"
  end
end

config = YAML::load(File.open(File.dirname(__FILE__) + "/../../config/database.yml"))
ENV['RAILS_ENV'] = worker_config['rails_env']

ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.establish_connection(config[ENV['RAILS_ENV']])
ActionMailer::Base.template_root = "views/" 
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.server_settings = {
	:address => "mail.streamburst.co.uk",
	:port => 25,
	:domain => "streamburst.tv",
	 :authentication => :login,
	 :user_name => "robert@streamburst.co.uk",
	 :password => "runner44"
}

heimdall_worker = HeimdallWorker.new(worker_config)
heimdall_worker.run
