$LOAD_PATH << File.expand_path(File.dirname(__FILE__))
require 'rubygems'
require 'yaml'

f = File.open( File.dirname(__FILE__) + '/config/worker.yml')
worker_config = YAML.load(f)

ENV['RAILS_ENV'] = worker_config['rails_env']

MASTER_TEST_MAX_COUNTER = 5000

MIN_FREE_SPACE_GB = 20
SLEEP_WAITING_FOR_FREE_SPACE_TIME = 120

SLEEP_WAITING_FOR_LOAD_TO_GO_DOWN = 120

SLEEP_WAITING_BETWEEN_RUNS = 5

EMAIL_REPORTING_INTERVALS = 86000

require File.dirname(__FILE__) + '/../../config/boot'
require "#{RAILS_ROOT}/config/environment" 

require 'sys/filesystem'
include Sys

require 'utils/logger.rb'
require 'utils/shell.rb'


require File.dirname(__FILE__) + '/../../app/models/admin_mailer.rb'

require 'yaml'

class Array
  def random(weights=nil)
    return random(map {|n| n.send(weights)}) if weights.is_a? Symbol
    weights ||= Array.new(length, 1.0)
    total = weights.inject(0.0) {|t,w| t+w}
    point = Kernel::rand * total
   
    zip(weights).each do |n,w|
    return n if w >= point
      point -= w
    end
  end
end

class WatermarkWorker
  def initialize(config)
    @logger = Logger.new("/var/log/audio_watermark_cache_"+ENV['RAILS_ENV']+".log")
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
  end

  def debug(text)
    @logger.debug("cs_debug %s: %s" % [log_time, text])
  end

  def process_target
    @download_id = @target.download_id
    @cache_type = @target.cache_type
    @download = Download.find_by_id(@download_id)
    product_format = ProductFormat.find_by_download_id @download_id 
    puts product_format.inspect
    @company_id = product_format.products[0].company.id
    @brand_id = product_format.products[0].brand.id
    @format_id = product_format.format.id
    @product = product_format.products[0]
    
    if product_format.format.video_codec == "x264_1153"
      @mp4box_file = "MP4BoxNew"
    else
      @mp4box_file = "MP4Box"
    end

    @media_watermark = MediaWatermark.new
    @media_watermark.cache_video_server_id = @worker_config["video_server_id"]
    @media_watermark.download_id = @download_id
    @media_watermark.reserved = true
    @media_watermark.cache_type = @cache_type
    @media_watermark.save
    
    @file_base = @download.file_name[0..@download.file_name.length-5]
    
    @path_to_original_mcf = "/var/content/originals/#{@company_id}/#{@brand_id}/#{@format_id}/#{@file_base}.mcf"
    @path_to_original_prep_h264 = "/var/content/originals/#{@company_id}/#{@brand_id}/#{@format_id}/#{@file_base}.prep.h264"
    @file_original_content_h264 = "/var/content/originals/#{@company_id}/#{@brand_id}/#{@format_id}/#{@file_base}.h264"

    @path_to_watermarked_folder = "/var/content/watermark_cache_"+ENV['RAILS_ENV']+"/#{@download_id}/#{@media_watermark.id}/"
    @path_to_watermarked_h264 = @path_to_watermarked_folder + "#{@download.file_name}.h264"
    @path_to_watermarked_wav = @path_to_watermarked_folder + "#{@download.file_name}.wav"
    @path_to_watermarked_final_m4a = @path_to_watermarked_folder + "#{@download.file_name}.m4a"
    @path_to_watermarked_final_temp_m4a = @path_to_watermarked_folder + "#{@download.file_name}.m4a.tmp"
    @path_to_watermarked_final_mp4 = @path_to_watermarked_folder + "#{@download.file_name}.mp4"
    @path_to_watermarked_final_temp_mp4 = @path_to_watermarked_folder + "#{@download.file_name}.mp4.tmp"
    FileUtils.mkpath(@path_to_watermarked_folder)

    @shell.execute("shuffle_V3 pcm -i #{@path_to_original_mcf} -o #{@path_to_watermarked_wav} -wz #{sprintf("%032b", @media_watermark.watermark)} -md5 -sprt 48000 -btdp 16")
    check_load_and_wait
    @shell.execute("mp4FastAACCmdlEnc #{product_format.format.audio_codec_options} -if \"#{@path_to_watermarked_wav}\" -of \"#{@path_to_watermarked_final_temp_m4a}\"")
    @shell.execute("mv #{@path_to_watermarked_final_temp_m4a} #{@path_to_watermarked_final_m4a}")
    File.delete(@path_to_watermarked_wav) if FileTest.exist?(@path_to_watermarked_wav)

    if @product and @product.use_video_watermarking
      cinea_watermark = sprintf("%016x", @media_watermark.watermark)
      cinea_watermark[2]='c'
      cinea_watermark[3]='0'
      cinea_watermark[4]='0'
      if product_format.format.format_type < 3
        @shell.execute("cinea_insert -m -i #{@path_to_original_prep_h264} -o #{@path_to_watermarked_h264} -e #{cinea_watermark}")      
      else
        @path_to_watermarked_h264 = @file_original_content_h264
      end    
      check_load_and_wait
    else
      @path_to_watermarked_h264 = @file_original_content_h264
    end

    if @cache_type == "mp4"
      check_load_and_wait
      @shell.execute("#{@mp4box_file} -flat -fps 25 -quiet -add #{@path_to_watermarked_final_m4a} -add #{@path_to_watermarked_h264} -new #{@path_to_watermarked_final_temp_mp4}")
      @shell.execute("mv #{@path_to_watermarked_final_temp_mp4} #{@path_to_watermarked_final_mp4}")
      File.delete(@path_to_watermarked_final_m4a) if FileTest.exist?(@path_to_watermarked_final_m4a)          
      File.delete(@path_to_watermarked_h264) if @path_to_watermarked_h264 != @file_original_content_h264 and FileTest.exist?(@path_to_watermarked_h264)          
    end
    
    @media_watermark.reload :lock => true
    @media_watermark.reserved = false
    @media_watermark.save
  end

  def poll_for_work
    @targets = WatermarkCacheTarget.find(:all)
    if @targets
      @target = @targets.random(:weight)
      debug(@target.inspect)
      count_conditions = "reserved = 0 AND used = 0 AND download_id = #{@target.download_id} AND cache_video_server_id = #{@worker_config["video_server_id"]}"
      unless @target.max_per_cache_server != 0 && MediaWatermark.count(:conditions => count_conditions) >= (@target.max_per_cache_server * @worker_config["load_factor"])
        process_target
      end  
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
      report = AdminMailer.create_report("Watermarking Unit #{@worker_config['video_server_id']} Reporting",
       "Free watermark space in GB #{freeGB} - Run count: #{@counter}\n\nLoad Average #{load_avg[0]}, #{load_avg[1]}, #{load_avg[2]}")
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
    loop do
      stat = Filesystem.stat("/var/content/watermark_cache_"+ENV['RAILS_ENV']+"/")
      freeGB = (stat.block_size * stat.blocks_available) /1024 / 1024 / 1024
      if @last_report_time+EMAIL_REPORTING_INTERVALS<Time.now.to_i
        email_progress_report(freeGB) unless ENV['RAILS_ENV']=="development"
        @last_report_time = Time.now.to_i
      end
      info("Free watermark space in GB #{freeGB} - Run count: #{@counter}")
      info("Load Average #{load_avg[0]}, #{load_avg[1]}, #{load_avg[2]}")      
      if load_avg[0] < @worker_config["max_load_average"]
        if freeGB > MIN_FREE_SPACE_GB
          if ENV['RAILS_ENV'] == 'development' && @counter > MASTER_TEST_MAX_COUNTER
            warn("Reached maximum number of test watermarks - sleeping for an hour")
            sleep(3600)
          else
            @counter = @counter + 1
            begin
              poll_for_work
            rescue => ex
              error("Problem with watermark worker")
              error(ex)
              error(ex.backtrace)
	      unless ActiveRecord::Base.connection.active?
	        unless ActiveRecord::Base.connection.reconnect!
		  error("Couldn't reestablish connection to MYSQL")
  	        end
	      end
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
ActionMailer::Base.smtp_settings = {
	:address => "mail.streamburst.co.uk",
	:port => 25,
	:domain => "streamburst.tv",
	 :authentication => :login,
	 :user_name => "robert@streamburst.co.uk",
	 :password => "runner44"
}

watermark_worker = WatermarkWorker.new(worker_config)
watermark_worker.run
