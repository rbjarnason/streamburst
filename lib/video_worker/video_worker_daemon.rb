$LOAD_PATH << File.expand_path(File.dirname(__FILE__))
require 'rubygems'
require 'yaml'

f = File.open( File.dirname(__FILE__) + '/config/worker.yml')
worker_config = YAML.load(f)

ENV['RAILS_ENV'] = worker_config['rails_env']

require 'utils/logger.rb'
require 'utils/shell.rb'
#require 'active_record'
#require "actionmailer"

require File.dirname(__FILE__) + '/../../config/boot'
require "#{RAILS_ROOT}/config/environment"

require File.dirname(__FILE__) + '/../../app/models/video_preparation_job.rb'
require File.dirname(__FILE__) + '/../../app/models/video_preparation_queue.rb'
require File.dirname(__FILE__) + '/../../app/models/video_preparation_mailer.rb'
require File.dirname(__FILE__) + '/../../app/models/admin_mailer.rb'
require File.dirname(__FILE__) + '/../../app/models/order.rb'
require File.dirname(__FILE__) + '/../../app/models/won_bid.rb'
require File.dirname(__FILE__) + '/../../app/models/bid.rb'
require File.dirname(__FILE__) + '/../../app/models/user.rb'
require File.dirname(__FILE__) + '/../../app/models/line_item.rb'

# Preparation Timing Types
PREPARATION_START_TIMING = 0
NO_WATERMARK_TIMING = 1
NO_WATERMARK_TIMING_NO_INTRO = 2
CACHED_WATERMARK_TIMING = 3
CACHED_WATERMARK_TIMING_NO_INTRO = 4
AUDIO_WATERMARK_TIMING = 5
AUDIO_WATERMARK_TIMING_NO_INTRO = 6
MP3_AUDIO_WATERMARK_TIMING = 7
WAV_AUDIO_WATERMARK_TIMING = 8
VIDEO_WATERMARK_TIMING = 9
VIDEO_WATERMARK_TIMING_NO_INTRO = 10

# Every 6 hours
EMAIL_REPORTING_INTERVALS = 86000

class VideoWorker
  attr_reader :logger

  def initialize(config)
    @logger = Logger.new("/var/log/video_worker_"+ENV['RAILS_ENV']+".log")
    @logger.level = Logger::INFO
    @shell = Shell.new(self)
    f = File.open( File.dirname(__FILE__) + '/config/worker.yml')
    @worker_config = YAML.load(f)
    @worker_config = config
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

  def setup_video_job  
    info("setup video job")
    I18n.locale = @args[:locale].to_sym
    @codec = @args[:format_video_codec]
    @download_id = @args[:download_id]
    @product_id = @args[:product_id]
    @user_id = @args[:user_id]
    @line_item_id = @args[:line_item_id]
    @use_audio_watermarking = @args[:use_audio_watermarking]
    @use_video_watermarking = @args[:use_video_watermarking]
    @media_watermark_gain = @args[:audio_watermark_gain]
    @user_country_code = @args[:country_code]
    @brand_name = @args[:brand_name]
    @product_title = @args[:product_title]
    @file_base = @args[:file_name][0..@args[:file_name].length-5]
    @welcome_text = "#{I18n.t(:Welcome)}, #{@args[:text]}"
    @set_to_h264 = @codec == "x264_600" || @codec == "x264_667" || @codec == "x264_1153" ? true : false
    
    if @codec == "x264_1153"
      @mp4box_file = "MP4BoxNew"
      product = Product.find(@product_id)
      @itags = "-itags \"name=#{product.title}:tracknum=#{product.program_id}:artist=#{@brand_name}:genre=#{product.genre}:created=#{product.created_at.strftime("%Y")}\""
    else
      @mp4box_file = "MP4Box"
      @itags = ""
    end

    @dir_personalized_root = "/var/content/personalized"
    if ENV['RAILS_ENV']=="development"
      @dir_personalized_intro = "#{@dir_personalized_root}/intros_development/#{@args[:user_id]}/#{@args[:brand_id]}/#{@args[:format_id]}"
    else
      @dir_personalized_intro = "#{@dir_personalized_root}/intros/#{@args[:user_id]}/#{@args[:brand_id]}/#{@args[:format_id]}"
    end
    FileUtils.mkpath(@dir_personalized_intro)
    @dir_personalized_content = "#{@dir_personalized_root}/file/#{@args[:user_id]}/#{@args[:download_id]}"
    FileUtils.mkpath(@dir_personalized_content)

    @file_original_content = "/var/content/originals/#{@args[:company_id]}/#{@args[:brand_id]}/#{@args[:format_id]}/#{@args[:file_name]}"

    if @use_audio_watermarking
      @file_original_content_h264 = "/var/content/originals/#{@args[:company_id]}/#{@args[:brand_id]}/#{@args[:format_id]}/#{@file_base}.h264"
      @file_original_content_mcf = "/var/content/originals/#{@args[:company_id]}/#{@args[:brand_id]}/#{@args[:format_id]}/#{@file_base}.mcf"
      @file_original_content_xvid = "/var/content/originals/#{@args[:company_id]}/#{@args[:brand_id]}/#{@args[:format_id]}/#{@file_base}.cmp"
    end

    if @use_video_watermarking
      @file_original_content_h264_prep_container = "/var/content/originals/#{@args[:company_id]}/#{@args[:brand_id]}/#{@args[:format_id]}/#{@file_base}.prep.h264"
      @file_personalized_content_h264_watermarked = "#{@dir_personalized_content}/#{@args[:file_name]}.watermarked.h264"
    end

    @file_personalized_template = "/var/content/templates/#{@args[:company_id]}/#{@args[:brand_id]}/#{@args[:format_id]}/personalized_template.avi"

    if @set_to_h264
      @file_personalized_template_sound = "/var/content/templates/common/silence_5_sec.mp4"
    else
      @file_personalized_template_sound = "/var/content/templates/common/mobile_silence_5_sec.mp4"
    end
        
    @file_personalized_text = "#{@dir_personalized_intro}/personalized_text.png"
    @file_personalized_text_out =  "#{@dir_personalized_intro}/personalized_text-0.png"
    @file_personalized_intro_raw_264 = "#{@dir_personalized_intro}/personalized_intro_raw.y4m"
    @file_personalized_intro_raw_xvid_avi = "#{@dir_personalized_intro}/personalized_intro_raw.avi"
    @file_personalized_intro_raw_xvid = "#{@dir_personalized_intro}/personalized_intro_raw.yuv"
    @file_personalized_intro_stats = "#{@dir_personalized_intro}/personalized_intro.stats"
    @file_personalized_intro_264 = "#{@dir_personalized_intro}/personalized_intro.264"
    @file_personalized_intro_xvid = "#{@dir_personalized_intro}/personalized_intro.m4v"

    @file_personalized_intro_tmp = "#{@dir_personalized_intro}/tmp_personalized_intro.mp4"
    @file_personalized_intro = "#{@dir_personalized_intro}/personalized_intro.mp4"
    
    @file_personalized_content_tmp = "#{@dir_personalized_content}/tmp_#{@args[:file_name]}"
    @file_personalized_content = "#{@dir_personalized_content}/#{@args[:file_name]}"
    @file_personalized_content_wav = "#{@dir_personalized_content}/#{@args[:file_name]}.wav"
    @file_personalized_content_m4a = "#{@dir_personalized_content}/#{@args[:file_name]}.m4a"
    @file_personalized_content_watermarked = "#{@dir_personalized_content}/#{@args[:file_name]}.watermarked.mp4"

    item = LineItem.find(@args[:line_item_id])
    if item.won_bid_id
      advertisement = item.won_bid.bid.advertisement
      for ad_format in advertisement.advertisements_formats
        if ad_format.format.id == @args[:format_id] 
          @advertisement_id = advertisement.id
          @advertisement_company_id = advertisement.company_id
          @advertisement_file_name = ad_format.advertisements_file.file_name
          @advertisement_file = "/var/content/advertisements/#{@advertisement_company_id}/#{@advertisement_id}/#{ad_format.format.id}/#{@advertisement_file_name}"
        end
      end
      error("Can't find advertisment... for won bid id #{item.won_bid_id}") unless @advertisement_file
    end
  end

  def delete_personalized_temp_files
    File.delete(@file_personalized_text) if FileTest.exist?(@file_personalized_text)    
    File.delete(@file_personalized_text_out) if FileTest.exist?(@file_personalized_text_out)    
    File.delete(@file_personalized_intro_raw_264) if FileTest.exist?(@file_personalized_intro_raw_264)    
    File.delete(@file_personalized_intro_raw_xvid_avi) if FileTest.exist?(@file_personalized_intro_raw_xvid_avi)    
    File.delete(@file_personalized_intro_raw_xvid) if FileTest.exist?(@file_personalized_intro_raw_xvid)    
    File.delete(@file_personalized_intro_stats) if FileTest.exist?(@file_personalized_intro_stats)    
    File.delete(@file_personalized_intro_264) if FileTest.exist?(@file_personalized_intro_264)    
    File.delete(@file_personalized_intro_xvid) if FileTest.exist?(@file_personalized_intro_xvid)
  end

  def create_personalized_intro
    info("create_personalized_intro")
    user = User.find(@user_id)
    set_job_status(@job.activity_timing_type, "#{I18n.t(:personalized_video_intro_for)} \"#{user.first_name} #{user.last_name}\"")

    @shell.execute("convert -antialias -size #{@args[:text_width]}x#{@args[:text_height]} xc:transparent -pointsize #{@args[:text_pointsize]} /usr/share/fonts/#{@args[:text_font]} \
                         -channel RGBA -gravity Center \
                         -fill \"#{@args[:text_fill]}\" -stroke \"#{@args[:text_stroke]}\" -draw \"text #{@args[:text_background_pos_x]},#{@args[:text_background_pos_y]} \\\"#{@welcome_text}\\\"\" #{@file_personalized_text}")

    if @set_to_h264
      @shell.execute("transcode -i #{@file_personalized_template} -o #{@file_personalized_intro_raw_264} -x ffmpeg -c 0-#{@args[:intro_total_frames]} -y yuv4mpeg -J \
                              logo=file=#{@file_personalized_text_out}:#{@args[:intro_position]}")
                                  
      @shell.execute("#{@codec} --pass 1 --stats #{@file_personalized_intro_stats} #{@args[:intro_pass_1_video_codec_options]} \
                                       #{@file_personalized_intro_raw_264} #{@args[:format_width]}x#{@args[:format_height]} --output /dev/null")
    
      @shell.execute("#{@codec} --pass 2 --stats #{@file_personalized_intro_stats} #{@args[:intro_pass_2_video_codec_options]} \
                                       --output #{@file_personalized_intro_264} #{@file_personalized_intro_raw_264} #{@args[:format_width]}x#{@args[:format_height]}")

      # #{@mp4box_file} -add "lwr_1.264" -add "portable_silence_5_sec.mp4" -fps 25 -new "lwr-muxed_3.mp4"
 #     @shell.execute("#{@mp4box_file}  -add #{@file_personalized_intro_264} -new #{@file_personalized_intro_tmp}")

      @shell.execute("#{@mp4box_file} -fps 25 -add #{@file_personalized_intro_264} -add #{@file_personalized_template_sound} -new #{@file_personalized_intro_tmp}")
      @shell.execute("mv #{@file_personalized_intro_tmp} #{@file_personalized_intro}")
    elsif @codec=="xvid"
      # transcode --import_fps 15 --export_fps 15 -i lwr_template_portible_raw.avi -o perz.avi -x ffmpeg -c 0-125 -y yuv4mpeg -J logo=file=personalizedtext_iPod.png:posdef=2
      @shell.execute("transcode --import_fps 15 --export_fps 15 -i #{@file_personalized_template} -o #{@file_personalized_intro_raw_xvid_avi} -x ffmpeg -c 0-#{@args[:intro_total_frames]} -y raw -J \
                              logo=file=#{@file_personalized_text_out}:#{@args[:intro_position]}")

      #ffmpeg -i /var/content/personalized/intros/2/2/5/personalized_intro_raw.avi -an out.yuv
      @shell.execute("ffmpeg -i #{@file_personalized_intro_raw_xvid_avi} -an #{@file_personalized_intro_raw_xvid}")

      # xvid_encraw -i "D:\Encoding\lwr\clips\mobile\clip_1_mobile.avs" -pass1 "D:\Encoding\lwr\clips\mobile\clip_1_mobile.stats" -bitrate 256 -kboost 100 -chigh 30 -clow 15 -overhead 0 -turbo -nopacked -vhqmode 0 -closed_gop -lumimasking -imin 3 -imax 5 -pmin 3 -pmax 5 -max_bframes 0 -threads 2 
      @shell.execute("xvid_encraw -type 0 -i #{@file_personalized_intro_raw_xvid} -pass1 #{@file_personalized_intro_stats} #{@args[:intro_pass_1_video_codec_options]} -w #{@args[:format_width]} -h #{@args[:format_height]}")
    
      # xvid_encraw -i "D:\Encoding\lwr\clips\mobile\clip_1_mobile.avs" -pass2 "D:\Encoding\lwr\clips\mobile\clip_1_mobile.stats" -bitrate 256 -kboost 100 -chigh 30 -clow 15 -overhead 0 -nopacked -vhqmode 0 -closed_gop -lumimasking -imin 3 -imax 5 -pmin 3 -pmax 5 -max_bframes 0 -threads 2  -o "D:\Encoding\lwr\clips\mobile\clip_1_mobile_0.m4v"      
      @shell.execute("xvid_encraw -type 0 -i #{@file_personalized_intro_raw_xvid} -pass2 #{@file_personalized_intro_stats} #{@args[:intro_pass_2_video_codec_options]} -o #{@file_personalized_intro_xvid} -w #{@args[:format_width]} -h #{@args[:format_height]}")

      # MP4Box -add "lwr_1.264" -add "portable_silence_5_sec.mp4" -fps 25 -new "lwr-muxed_3.mp4"
      @shell.execute("#{@mp4box_file} -fps 15 -3gp -add #{@file_personalized_intro_xvid} -add #{@file_personalized_template_sound} -new #{@file_personalized_intro_tmp}")
      @shell.execute("mv #{@file_personalized_intro_tmp} #{@file_personalized_intro}")
    end
    delete_personalized_temp_files
  end

  def mux_final_file
    info("mux final file")
    user = User.find(@user_id)
    set_job_status(@job.activity_timing_type, "#{I18n.t(:unique_video_copy)} \"#{user.first_name} #{user.last_name}\"")
    info("mux_final_file")
    if @use_audio_watermarking || @use_video_watermarking
      if @set_to_h264
        if @media_watermark.cache_type == "mp4"
          @file_personalized_content_watermarked = @file_personalized_content_mp4
        else          
           @file_original_content_h264 = @file_personalized_content_h264_watermarked if @use_video_watermarking
           @shell.execute("#{@mp4box_file} -flat -quiet -fps 25 -add #{@file_personalized_content_m4a} -add #{@file_original_content_h264} -new #{@file_personalized_content_watermarked}")
           File.delete(@file_personalized_content_m4a) if FileTest.exist?(@file_personalized_content_m4a)
           File.delete(@file_personalized_content_h264_watermarked) if @file_personalized_content_h264_watermarked and FileTest.exist?(@file_personalized_content_h264_watermarked) and @file_personalized_content_h264_watermarked != @file_original_content_h264
        end
#        set_job_status(@job.activity_timing_type, "Finalizing preparation for \"#{user.first_name} #{user.last_name}\"")
        if @advertisement_file
          @shell.execute("#{@mp4box_file} #{@itags} -flat -quiet -isma -cat #{@file_personalized_intro} -cat #{@advertisement_file} -cat #{@file_personalized_content_watermarked} -new #{@file_personalized_content_tmp}")
        else
          @shell.execute("#{@mp4box_file} #{@itags} -flat -quiet -isma -cat #{@file_personalized_intro} -cat #{@file_personalized_content_watermarked} -new #{@file_personalized_content_tmp}")
        end
        @shell.execute("mv #{@file_personalized_content_tmp} #{@file_personalized_content}")
      elsif @codec=="xvid"
        @shell.execute("#{@mp4box_file} -flat -quiet -fps 15 -add #{@file_personalized_content_m4a} -add #{@file_original_content_xvid} -new #{@file_personalized_content_watermarked}")
        File.delete(@file_personalized_content_m4a) if FileTest.exist?(@file_personalized_content_m4a)
        if @advertisement_file
          @shell.execute("#{@mp4box_file} -quiet -flat -fps 15 -3gp -cat #{@file_personalized_intro} -cat #{@advertisement_file} -cat #{@file_personalized_content_watermarked} -new #{@file_personalized_content_tmp}")
        else
          @shell.execute("#{@mp4box_file} -quiet -flat -fps 15 -3gp -cat #{@file_personalized_intro} -cat #{@file_personalized_content_watermarked} -new #{@file_personalized_content_tmp}")
        end        
        @shell.execute("mv #{@file_personalized_content_tmp} #{@file_personalized_content}")
      end
	    File.delete(@file_personalized_content_watermarked) if FileTest.exist?(@file_personalized_content_watermarked)
    else
      if @set_to_h264
        if @advertisement_file
          @shell.execute("#{@mp4box_file} #{@itags} -flat -quiet -isma -cat #{@file_personalized_intro} -cat #{@advertisement_file} -cat #{@file_original_content} -new #{@file_personalized_content_tmp}")
        else
          @shell.execute("#{@mp4box_file} #{@itags} -flat -quiet -isma -cat #{@file_personalized_intro} -cat #{@file_original_content} -new #{@file_personalized_content_tmp}")
        end
        @shell.execute("mv #{@file_personalized_content_tmp} #{@file_personalized_content}")
      elsif @codec=="xvid"        
        if @advertisement_file
          @shell.execute("#{@mp4box_file} -flat -quiet -fps 15 -3gp -cat #{@file_personalized_intro} -cat #{@advertisement_file} -cat #{@file_original_content} -new #{@file_personalized_content_tmp}")
        else
          @shell.execute("#{@mp4box_file} -flat -quiet -fps 15 -3gp -cat #{@file_personalized_intro} -cat #{@file_original_content} -new #{@file_personalized_content_tmp}")
        end
        @shell.execute("mv #{@file_personalized_content_tmp} #{@file_personalized_content}")
      end
    end
    @success = true if FileTest.exist?(@file_personalized_content)
  end
  
  def media_watermark
    info("media_watermark")
    user = User.find(@user_id)
    set_job_status(@job.activity_timing_type, "#{I18n.t(:unique_video_copy)} \"#{user.first_name} #{user.last_name}\"")
    @skip_watermark = false
    @skip_watermark_creation = false
    @media_watermark = MediaWatermark.find_by_download_id(@download_id, :conditions => "used = 0 AND reserved = 0 AND cache_type = 'mp4' AND cache_video_server_id = #{@worker_config['video_server_id']}", :lock => true)
    unless @media_watermark
      @media_watermark = MediaWatermark.find_by_download_id(@download_id, :conditions => "used = 0 AND reserved = 0 AND cache_video_server_id = #{@worker_config['video_server_id']}", :lock => true)
    end
    if @media_watermark
      @file_personalized_content_m4a = "/var/content/watermark_cache_"+ENV['RAILS_ENV']+"/#{@download_id}/#{@media_watermark.id}/#{@args[:file_name]}.m4a"
      @file_personalized_content_mp4 = "/var/content/watermark_cache_"+ENV['RAILS_ENV']+"/#{@download_id}/#{@media_watermark.id}/#{@args[:file_name]}.mp4"
      test_file = ""
      if @media_watermark.cache_type == "mp4"
        test_file = @file_personalized_content_mp4
      else
        test_file = @file_personalized_content_m4a
      end
      if FileTest.exist?(test_file)
        @skip_watermark_creation = true
      else
        error("Didn't find the file for this cached watermark: #{test_file}")
        @file_personalized_content_m4a = "#{@dir_personalized_content}/#{@args[:file_name]}.m4a"
        @file_personalized_content_mp4 = "#{@dir_personalized_content}/#{@args[:file_name]}.mp4"
        @media_watermark.cache_type = ""
      end
    else
      @media_watermark = MediaWatermark.new
    end
    @media_watermark.download_id = @download_id
    @media_watermark.product_id = @product_id
    @media_watermark.user_id = @user_id
    @media_watermark.line_item_id = @line_item_id
    @media_watermark.reserved = true
    @media_watermark.has_video_watermark = true if @use_video_watermarking
    @media_watermark.save
    unless @skip_watermark_creation
      if @no_intro
        if @use_video_watermarking
          set_job_status(VIDEO_WATERMARK_TIMING_NO_INTRO)
        else
          set_job_status(AUDIO_WATERMARK_TIMING_NO_INTRO)
        end
      else
        if @use_video_watermarking
          set_job_status(VIDEO_WATERMARK_TIMING)
        else
          set_job_status(AUDIO_WATERMARK_TIMING)
        end
      end
      product_format = ProductFormat.find_by_download_id @download_id
      @shell.execute("shuffle_V3 pcm -i #{@file_original_content_mcf} -o #{@file_personalized_content_wav} -wz #{sprintf("%032b", @media_watermark.watermark)} -md5 -sprt 48000 -btdp 16")
      @shell.execute("mp4FastAACCmdlEnc #{product_format.format.audio_codec_options} -if \"#{@file_personalized_content_wav}\" -of \"#{@file_personalized_content_m4a}\"")
      if @use_video_watermarking
        cinea_watermark = sprintf("%016x", @media_watermark.watermark)
        cinea_watermark[2]='c'
        cinea_watermark[3]='0'
        cinea_watermark[4]='0'
        if product_format.format.format_type < 3
          @shell.execute("cinea_insert -m -i #{@file_original_content_h264_prep_container} -o #{@file_personalized_content_h264_watermarked} -e #{cinea_watermark}")
        else
          @file_personalized_content_h264_watermarked = @file_original_content_h264
        end
      end
      File.delete(@file_personalized_content_wav) if FileTest.exist?(@file_personalized_content_wav)
    else
      if @no_intro
        set_job_status(CACHED_WATERMARK_TIMING_NO_INTRO)
      else
        set_job_status(CACHED_WATERMARK_TIMING)
      end
    end
  end
  
  def email_to_user
    info("emailing to user id #{@job.user_id}")
    begin
      ready_email = VideoPreparationMailer.create_preparation_complete(@job.order, @job.content_store_host, @brand_name, @product_title, @job.job_key)
      ready_email.set_content_type("text/html")
      VideoPreparationMailer.deliver(ready_email)
    rescue => ex
      error(ex)
      error(ex.backtrace)
    end
    #TODO: Add time of email
  end

  def set_job_status(activity_timing_type, status_text = nil)
    if @job
      info("Set Job Status: #{activity_timing_type} #{status_text}")

      VideoPreparationJob.transaction do
        @job.reload(:lock => true)
        if @job.activity_timing_type != activity_timing_type
          @job.activity_timing_type = activity_timing_type
          @job.setup_timings
        end
        @job.status_text = status_text if status_text
        @job.save
      end
    end
  end

  def update_job_end_status
    info("update_job_end_status")
    if @job != nil
      VideoPreparationJob.transaction do
        @job.reload(:lock => true)
        @job.no_work_done = @no_work_done
        @job.complete = true
        @job.completed_at = Time.now
        @job.success = @success
        @job.in_progress = 0
        @job.progress = 0
        @job.status_text = "Preparation Complete"
        @job.save
        @job.remove_from_video_preparation_queue
      end
      email_to_user if @job.email_when_finished && @success == true
    end
    if @use_audio_watermarking && @media_watermark && @success == true
      MediaWatermark.transaction do
        @media_watermark.reload :lock => true
        @media_watermark.used = true
        @media_watermark.save
      end
      if @skip_watermark_creation
        File.delete(@file_personalized_content_m4a) if FileTest.exist?(@file_personalized_content_m4a)    
      end
    end
  end

  def process_video_job
    if @use_audio_watermarking
      set_job_status(CACHED_WATERMARK_TIMING)
    else
      set_job_status(NO_WATERMARK_TIMING)
    end
    setup_video_job
    unless FileTest.exist?(@file_personalized_content)
      @no_work_done = false
      unless FileTest.exist?(@file_personalized_intro)
        create_personalized_intro
      else
        if @use_audio_watermarking
          set_job_status(CACHED_WATERMARK_TIMING_NO_INTRO)
        else
          set_job_status(NO_WATERMARK_TIMING_NO_INTRO)
        end
        @no_intro = true
      end
      media_watermark if @use_audio_watermarking
      mux_final_file
    else
      info("No work done")
      @no_work_done = true
      @success = true
    end
    update_job_end_status
  end

  def setup_audio_job  
    info("setup audio job")
    @download_id = @args[:download_id]
    @product_id = @args[:product_id]
    @user_id = @args[:user_id]
    @line_item_id = @args[:line_item_id]
    @use_audio_watermarking = @args[:use_audio_watermarking]
    @user_country_code = @args[:country_code]
    @brand_name = @args[:brand_name]
    @product_title = @args[:product_title]
    @file_base = @args[:file_name][0..@args[:file_name].length-5]

    @file_original_content = "/var/content/originals/#{@args[:company_id]}/#{@args[:brand_id]}/#{@args[:format_id]}/#{@args[:file_name]}"
    if @use_audio_watermarking
      @file_original_content_mcf = "/var/content/originals/#{@args[:company_id]}/#{@args[:brand_id]}/#{@args[:format_id]}/#{@file_base}.mcf"
    end
    
    @dir_personalized_root = "/var/content/personalized"
    @dir_personalized_content = "#{@dir_personalized_root}/file/#{@args[:user_id]}/#{@args[:download_id]}"
    FileUtils.mkpath(@dir_personalized_content)
    
    @file_personalized_content_tmp = "#{@dir_personalized_content}/tmp_#{@args[:file_name]}"
    @file_personalized_content = "#{@dir_personalized_content}/#{@args[:file_name]}"
  end

  def prepare_final_audio_file
    info("media_watermark")
    user = User.find(@user_id)
    set_job_status(@job.activity_timing_type, "#{I18n.t(:unique_video_copy)} \"#{user.first_name} #{user.last_name}\"")
    @skip_watermark = false
    @skip_watermark_creation = false
    @media_watermark = MediaWatermark.new
    
    @media_watermark.download_id = @download_id
    @media_watermark.product_id = @product_id
    @media_watermark.user_id = @user_id
    @media_watermark.line_item_id = @line_item_id
    @media_watermark.reserved = true
    @media_watermark.save
    product_format = ProductFormat.find_by_download_id @download_id
    if @args[:audio_codec][0..6] == "mp3-320"
      @shell.execute("shuffle_V3 mp3 -i #{@file_original_content_mcf} -o #{@file_personalized_content_tmp} -wz #{sprintf("%032b", @media_watermark.watermark)} -md5 -bitr 320")
    elsif @args[:audio_codec][0..6] == "mp3-160"
      @shell.execute("shuffle_V3 mp3 -i #{@file_original_content_mcf} -o #{@file_personalized_content_tmp} -wz #{sprintf("%032b", @media_watermark.watermark)} -md5 -bitr 160")
    elsif @args[:audio_codec] == "wav-24-48"
      @shell.execute("shuffle_V3 pcm -i #{@file_original_content_mcf} -o #{@file_personalized_content_tmp} -wz #{sprintf("%032b", @media_watermark.watermark)} -md5 -btdp 24 -sprt 48000")
    elsif @args[:audio_codec] == "wav-24-441"
      @shell.execute("shuffle_V3 pcm -i #{@file_original_content_mcf} -o #{@file_personalized_content_tmp} -wz #{sprintf("%032b", @media_watermark.watermark)} -md5 -btdp 24 -sprt 44100")
    elsif @args[:audio_codec] == "wav-16-48"
      @shell.execute("shuffle_V3 pcm -i #{@file_original_content_mcf} -o #{@file_personalized_content_tmp} -wz #{sprintf("%032b", @media_watermark.watermark)} -md5 -btdp 16 -sprt 48000")
    elsif @args[:audio_codec] == "wav-16-441"
      @shell.execute("shuffle_V3 pcm -i #{@file_original_content_mcf} -o #{@file_personalized_content_tmp} -wz #{sprintf("%032b", @media_watermark.watermark)} -md5 -btdp 16 -sprt 44100")
    else
      error("Cant find valid audio codec options")
    end
    @shell.execute("mv #{@file_personalized_content_tmp} #{@file_personalized_content}")
    @success = true if FileTest.exist?(@file_personalized_content)
  end

  def process_audio_job
    if @args[:audio_codec][0..2] == "mp3"
      set_job_status(MP3_AUDIO_WATERMARK_TIMING)
    elsif @args[:audio_codec][0..2] == "wav"
      set_job_status(WAV_AUDIO_WATERMARK_TIMING)
    end

    setup_audio_job
    unless FileTest.exist?(@file_personalized_content)
      @no_work_done = false
      prepare_final_audio_file
    else
      info("No work done")
      @no_work_done = true
      @success = true
    end
    update_job_end_status
  end

  def email_progress_report
    info("emailing report")
    begin
      report = AdminMailer.create_report("Video Unit #{@worker_config['video_server_id']} Reporting",
        "Nothing to report yet...")
      report.set_content_type("text/html")
      AdminMailer.deliver(report)
    rescue => ex
      error(ex)
      error(ex.backtrace)
    end
    #TODO: Add time of email
  end
  
  def poll_for_work
    if @last_report_time+EMAIL_REPORTING_INTERVALS<Time.now.to_i
      email_progress_report unless ENV['RAILS_ENV']=="development"
      @last_report_time = Time.now.to_i
    end
    @success = false 
    @job = nil
    VideoPreparationJob.transaction do
      @job = VideoPreparationQueue.find_by_name("main").video_preparation_jobs.find_highest_priority
      if @job
        info("Got job: #{@job.inspect}")
        @job.preparation_started(@worker_config["video_server_id"])
      end
    end
    if @job
      @args = YAML::load(@job.preparation_args)
      unless @args[:audio_only]
        process_video_job
      else
        process_audio_job
      end
      poll_for_work # See right away if there is another job
    end
  end

  def run
  info("Starting run loop")
    loop do
      begin
        poll_for_work
      rescue => ex
        error("Problem with video worker")
        error(ex)
        error(ex.backtrace)
        update_job_end_status
	unless ActiveRecord::Base.connection.active?
          unless ActiveRecord::Base.connection.reconnect!
            error("Couldn't reestablish connection to MYSQL")
          end
        end
      end
      sleep(@worker_config["sleep_for"])
    end
  end
end

config = YAML::load(File.open(File.dirname(__FILE__) + "/../../config/database.yml"))

ENV['RAILS_ENV'] = worker_config['rails_env']

video_worker = VideoWorker.new(worker_config)

ActiveRecord::Base.logger = video_worker.logger
ActiveRecord::Base.establish_connection(config[ENV['RAILS_ENV']])
ActionMailer::Base.template_root = "views/" 
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.default_charset = 'ISO-8859-1'
ActionMailer::Base.default_arguments_charset = 'UTF-8'
ActionMailer::Base.smtp_settings = {
	:address => "mail.streamburst.co.uk",
	:port => 25,
	:domain => "streamburst.tv",
	 :authentication => :login,
	 :user_name => "robert@streamburst.co.uk",
	 :password => "runner44"
}

video_worker.run

