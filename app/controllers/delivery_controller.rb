#TODO: Clean this up make more DRY...
require 'timeout'
require 'yaml'

class DeliveryController < ApplicationController
  layout :store_layout
  before_filter :set_initial_category
  before_filter :setup_cart, :except => :empty_cart

  helper :delivery
  include DeliveryHelper

  VIDEO_PREPARATION_JOB_TIMEOUT_SECONDS = 300 # 5 minutes...

  # Preparation Timing Types
  PREPARATION_START_TIMING = 0
  NO_WATERMARK_TIMING = 1
  NO_WATERMARK_TIMING_NO_INTRO = 2
  CACHED_AUDIO_WATERMARK_TIMING = 3
  CACHED_AUDIO_WATERMARK_TIMING_NO_INTRO = 4
  AUDIO_WATERMARK_TIMING = 5
  AUDIO_WATERMARK_TIMING_NO_INTRO = 6
  MP3_AUDIO_WATERMARK_TIMING = 7
  WAV_AUDIO_WATERMARK_TIMING = 8

  def index
    redirect_to :action => 'my_downloads'
  end

  def show_downloads
    @downloads_key = params[:downloads_key]
    unless @downloads_key
      redirect_to_index(t(:Missing_downloads_job))
      return true
    end
    @order = Order.find_by_downloads_key(@downloads_key)
    redirect_to_index(t(:not_your_download_job)) unless @order && @order.user_id == session[:user_id]
    @order.expire_discount_vouchers if @order
    session[:last_downloads_key] = @downloads_key
    if xml_request?
      respond_to do |accepts|
        accepts.html
        accepts.xml { render :file => 'delivery/show_downloads.rxml', :layout => false, :use_full_path => true }
      end
    end
  end

  def my_downloads
    @my_orders = Order.find_all_by_user_id(session[:user_id], :conditions => "complete = 1")
    #TODO: Look into why we are not expiring disount vouchers here...
  end

  def get_download
    @downloads_key = params[:downloads_key]
    session[:last_downloads_key] = @downloads_key
    
    orders = Order.find_all_by_downloads_key(@downloads_key)
    for order in orders
      if order.user_id == session[:user_id]
        @order = order
      end
    end

    @download = Download.find(params[:id])
    @format = Format.find(params[:format_id])
    @product = Product.find(params[:product_id])

    # Checks for order
    redirect_to_index(t(:this_is_not_your_order)) unless @order and @order.user_id == session[:user_id]

    redirect_to_index(t(:order_not_fully_processed)) unless @order.complete == true

    #Check for right product
    found_product = false
    for line_item in @order.line_items
      found_product = true if line_item.product.id == @product.id
      found_product = true if params[:parent_product_id] and params[:parent_product_id] != "" and line_item.product.id == params[:parent_product_id].to_i
    end

    redirect_to_index(t(:product_not_part_of_order)) unless found_product == true
    
    @file_size = @download.file_size_mb
    # Reset all temp session varibles
    session[:video_preparation_failure_flag] = nil
    session[:video_preparation_user_cancel] = nil

    begin
      job = VideoPreparationJob.find_by_user_id(session[:user_id], :conditions => "active = 1 AND complete = 0 AND download_id = #{@download.id}")
      #TODO: Fix race condition here by adding job.complete_time and releaseing the job after 30 seconds job.complete == true
      #TODO: Really check this below timeout out...
      if job && job.added_to_queue_time && job.added_to_queue_time < (Time.now.to_i - VIDEO_PREPARATION_JOB_TIMEOUT_SECONDS)
        info("user_id: #{session[user_id]} job_key: #{job.job_key} TIMEOUT")
        begin
          job.timed_out = true
          job.deactivate
        rescue => ex
          error(ex)
          error(ex.backtrace.join("\n"))
        end
        job = nil
      elsif job && VideoPreparationQueue.find_by_name("main").video_preparation_jobs.find_by_job_key(job.job_key) == nil && VideoPreparationQueue.find_by_name("wait").video_preparation_jobs.find_by_job_key(job.job_key) == nil
        info("user_id: #{session[user_id]} job_key: #{job.job_key} DEACTIVATED BY NOT BEING IN ANY QUEUE")
        begin
          job.deactivate
        rescue => ex
          error(ex)
          error(ex.backtrace.join("\n"))
        end
        job = nil
      end      
      unless job
        begin
          job = VideoPreparationJob.new
          job.preparation_args = create_args_for_content_worker(false, @order, @product, @format, @download, params[:line_item_id])
          job.residence_country = @order.paypal_residence_country
          job.user_id = session[:user_id]
          job.download_id = params[:id]
          job.format_id = params[:format_id]
          job.product_id = params[:product_id]
          job.downloads_key = params[:downloads_key]
          job.content_store_host = request.host
          job.order_id = @order.id
          job.file_size_mb = @file_size
          job.active = true
          job.setup_timings
          job.setup_status_text
          job.save
          job.add_to_video_preparation_queue
          job.reload
          if @format.audio_only && @format.audio_codec[0..2] == "mp3"
            @preparation_time_estimation_seconds = 6
          elsif @format.audio_only && @format.audio_codec[0..2] == "wav"
            @preparation_time_estimation_seconds = 9
          else
            @preparation_time_estimation_seconds = (job.setup_timings).to_i + 15
          end
          @status_text = job.setup_status_text
          @job_key = job.job_key
          info("Saved job: " + job.inspect)
        rescue => ex
          error(ex)
          error(ex.backtrace.join("\n"))
          flash[:notice] = t(:video_prep_failed)
          notify_administrators("Video Preparation Failed in get_downloads", "Video Preparation Failed for user: #{session[:user_id]}")
          redirect_to(:action => "show_downloads", :downloads_key => params[:downloads_key])
        end
      else
        info("Found an active job job: #{job.inspect}")
        if @download.id == job.download_id
          @preparation_time_estimation_seconds = (job.setup_timings).to_i
          @job_key = job.job_key
          @status_text = job.status_text
        end
      end
    rescue => ex
      error(ex)
      error(ex.backtrace.join("\n"))
    end
    if xml_request?
      respond_to do |accepts|
        accepts.html
        accepts.xml { render :file => 'delivery/get_download.rxml', :layout => false, :use_full_path => true }
      end
    end
  end

  def cancel_video_preparation_job(render_nothing = false)
    begin  
      session[:video_preparation_user_cancel] = true      
      job = VideoPreparationJob.find_by_job_key(params[:job_key])
      if job
        #TODO: Find away to cancel the video server if its already processing
        job.cancelled = true
        job.deactivate
        info("User Cancelled Job: #{job.job_key}")
        redirect_to_downloads(t(:video_job_cancelled), job.downloads_key) unless render_nothing == true
      else
        redirect_to_downloads(t(:video_job_cancelled), session[:last_downloads_key]) unless render_nothing == true
      end
    rescue => ex
      error(ex)
      error(ex.backtrace.join("\n"))
      redirect_to_downloads(t(:video_job_cancelled_failed), session[:last_downloads_key]) unless render_nothing == true
    end
    if xml_request?
      respond_to do |accepts|
        accepts.html
        accepts.xml { render :file => 'delivery/cancel_video_preparation_job.rxml', :layout => false, :use_full_path => true }
      end
    end
  end

  def email_when_ready
    retry_count = 5
    begin  
      job = VideoPreparationJob.find_by_job_key(params[:job_key])
      if job
        unless job.complete
          #TODO: Deal with race conditions if job has already been processed
          begin
            job.email_when_finished = true
            job.status_text = "You will be emailed when this job is finished"
            job.save
          rescue
            error("Save failed for job")
            job.reload
            if job.complete
              redirect_to( :action => 'content_ready', :job_key => params[:job_key] )
            elsif retry_count > 0
              retry_count -= 1
              retry
            else
              raise "retry bailed out"
            end
          else 
            redirect_to_downloads(t(:email_alert_for_download), session[:last_downloads_key])
          end
        else
          redirect_to( :action => 'content_ready', :job_key => params[:job_key] )
        end
      else
        render :nothing => true
      end
    rescue => ex
      error(ex)
      error(ex.backtrace.join("\n"))
      redirect_to_downloads(t(:email_alert_for_download_failed), session[:last_downloads_key])
    end
    if xml_request?
      respond_to do |accepts|
        accepts.html
        accepts.xml { render :file => 'delivery/email_when_ready.rxml', :layout => false, :use_full_path => true }
      end
    end
  end

  def get_prepare_content_progress
    if request.xhr? || xml_request?
      cancel_flag = false
      redirect_flag = false
      begin
        job = VideoPreparationJob.find_by_job_key(params[:job_key])
        user = User.find(session[:user_id])
        if job
          @xml_request = xml_request?
          @job = job
          total_time_estimate = job.estimated_preparation_time.to_i
          @preparation_time_estimation_seconds = ((job.added_to_queue_time + total_time_estimate) - Time.now.to_i).to_i + 17
          if job.email_when_finished && rand(2)==1
            @status_text = "You will be emailed when this job is finished"
          else
            @status_text = job.status_text
          end
          
          @preparation_time_estimation_seconds = 60 if @preparation_time_estimation_seconds == nil
          @preparation_time_estimation_seconds = 10 if @preparation_time_estimation_seconds <= 10

          unless @xml_request
            render :update do |page|
              if job.complete == true
                if job.success == true
                  page.redirect_to( :action => 'content_ready', :job_key => params[:job_key] ) 
                else
                  flash[:notice] = t(:video_prep_failed)
                  session[:video_preparation_failure_flag] = true
                  page.redirect_to :action => :show_downloads, :downloads_key => session[:last_downloads_key]
                end
              else
                logger.info("Prep time estimate #{@preparation_time_estimation_seconds}")
                new_status = "<div style=\"text-align: left\">#{@status_text}</div>"
                page.call('progressText', 'progresstext', new_status)
                page << "seconds = #{@preparation_time_estimation_seconds}"
              end
            end
          end
          if session[:video_preparation_failure_flag]
            job.deactivate
            notify_administrators("Video Preparation Failed", "Video Preparation Failed for user: #{session[:user_id]}")
            error("Video Preparation Failed")
          end
        else
          error("No video_preparation_key found")
          #TODO: Time this out and do page.redirect_after some time using the completed_at time
        end
      rescue => ex
        error(ex)
        error(ex.backtrace.join("\n"))
      end
      if xml_request?
        respond_to do |accepts|
          accepts.html
          accepts.xml { render :file => 'delivery/get_prepare_content_progress.rxml', :layout => false, :use_full_path => true }
        end
      end
    else
      error("Calling get content process without XHR")
    end
  end

  def content_ready
    begin
      job = VideoPreparationJob.find_by_job_key(params[:job_key])
      if job
        @format_id = job.format_id
        @product_id = job.product_id
        @download_id = job.download_id
        @video_server_hostname = "video#{job.video_server_id}.streamburst.tv"
        @downloads_key = job.downloads_key
        @status_text = "Your Content is Ready for Download"
        @job_key = job.job_key
        info("Job being deactivated #{job.inspect}")
        begin
          #TODO: Mark job as used
          job.deactivate
        rescue
          warn("Couldn't save job: #{$!}")
        end
      else
        flash[:notice] = t(:video_prep_failed)
        notify_administrators("Video Preparation Failed", "Video Preparation Failed for user: #{session[:user_id]}")
        redirect_to_downloads(t(:video_prep_failed), session[:last_downloads_key]) unless render_nothing == true
        error("Key not found")
      end
    rescue => ex
      error(ex)
      error(ex.backtrace.join("\n"))
    end
    @format = Format.find(@format_id) if @format_id
    @product = Product.find(@product_id) if @product_id
    @download = Download.find(@download_id) if @download_id
    if xml_request?
      respond_to do |accepts|
          accepts.html
          accepts.xml { render :file => 'delivery/content_ready.rxml', :layout => false, :use_full_path => true }
      end
    end
  end

  private
  def helpers
    Helper.instance
  end

  class Helper
    include Singleton
    include ActionView::Helpers::TextHelper
  end

  def create_args_for_content_worker(only_intro, order, product, format, download, line_item_id)
    full_name = helpers.truncate("#{order.first_name} #{order.last_name}", :length=>format.text_truncate_len)
    args = { :only_intro => only_intro,
             :user_id => order.user_id,
             :country_code => @country_code,
             :download_id => download.id,
             :format_id => format.id,
             :product_id => product.id,
             :brand_id => product.brand_id,
             :company_id => product.company_id,
             :line_item_id => line_item_id,
             :file_name => download.file_name,
             :text => "#{full_name}",
             :text_width => format.text_width,
             :text_height => format.text_height,
             :text_pointsize => format.text_pointsize,
             :text_font => format.text_font,
             :text_main_pos_x => format.text_main_pos_x,
             :text_main_pos_y => format.text_main_pos_y,
             :text_gaussian_value => format.text_gaussian_value,
             :text_fill => @brand.welcome_text_color,
             :text_stroke => @brand.welcome_text_background_color,
             :text_background_pos_x => format.text_background_pos_x,
             :text_background_pos_y => format.text_background_pos_y,
             :text_background_enabled => format.text_background_enabled, 
             :intro_total_frames => format.intro_total_frames,
             :intro_position => @brand.id == 7 && format.id == 6 ? "posdef=5" : format.intro_position,
             :intro_pass_1_video_codec_options => format.pass_1_video_codec_options,
             :intro_pass_2_video_codec_options => format.pass_2_video_codec_options,
             :format_width => format.px_width,
             :format_height => format.px_height,
             :format_video_codec => format.video_codec,
             :use_audio_watermarking => product.use_audio_watermarking,
             :use_video_watermarking => product.use_video_watermarking,
             :audio_watermark_gain => product.audio_watermark_gain,
             :brand_name => product.brand.name,
             :product_title => product.title,
             :audio_only => format.audio_only, 
             :audio_codec => format.audio_codec,
             :locale => I18n.locale.to_s}
  end

  def redirect_to_downloads(msg, downloads_key)
    flash[:notice] = msg if msg
    error("redirect_to_downloads - #{msg}")
    redirect_to :action => :show_downloads, :downloads_key => downloads_key
    return false
  end
end

