class MobileController < DeliveryController
  MOBILE_FORMAT_ID = 5
  CLIP_CATEGORY_ID = 2
  skip_before_filter :check_authentication, :only => :index
  skip_before_filter :check_authorization, :only => :index
  skip_before_filter :redirect_to_ssl
  
  def index
    info("In Mobile Controller")
    session[:user_id] = nil
    if request.post?
      user = User.authenticate(params[:email], params[:password])
      if user
        session[:user_id] = user.id
        session[:user_email] = user.email
        redirect_to(:action => "show_downloads")
      else
        flash[:notice] = "Invalid user/password combination"
      end
    end
  end

  def show_downloads
    info("In Mobile Controller show downloads")
    @mobile_format_id = MOBILE_FORMAT_ID
    @clip_category_id = CLIP_CATEGORY_ID
    @orders = Order.find_all_by_user_id(session[:user_id], :order => "created_at")   
  end

  def download
    info("In Mobile Controller")
    @order = Order.find(params[:order_id])
    unless @order.user_id == session[:user_id]
      redirect_to_index("This is not your download key!")
    end
    @order.expire_discount_vouchers
    cancel_video_preparation_job(true)
    @download = Download.find(params[:id])
    @format = Format.find(params[:format_id])
    @product = Product.find(params[:product_id])
    exit_content_creation = false
  
    middleman, middleman_uri, content_server_prefix = get_new_middleman
    if middleman
      @content_server_prefix = content_server_prefix
      content_worker_args = create_args_for_content_worker(false, @order, @product, @format, @download)
      begin
        key = VideoPreparationJobKey.new
        key.job_key = middleman.new_worker(:class => :content_worker, :args => content_worker_args)
        key.content_server_prefix = content_server_prefix
        key.middleman_uri = middleman_uri
        key.user_id = session[:user_id]
        key.download_id = params[:id]
        key.format_id = params[:format_id]
        key.product_id = params[:product_id]
        key.downloads_key = "na"
        key.save
        info("Saved key: " + key.inspect)
      rescue => ex
        exit_content_creation = true
        error(ex)
        error(ex.backtrace)
        error("Couln't save key")
        flash[:notice] = "Video Preparation Failed - Website Administrators have been notified"
        notify_administrators("Video Preparation Failed in content_ready", "Video Preparation Failed for user: #{session[:user_id]}")
        redirect_to(:action => "show_downloads", :downloads_key => params[:downloads_key])
      end
    end
        
    while (exit_content_creation==false)
       sleep(5)
       key.reload
       if key.complete
         unless key.success      
           notify_administrators("Video Preparation Failed in content_ready", "Video Preparation Failed for user: #{session[:user_id]}")
           redirect_to(:action => "show_downloads", :downloads_key => params[:downloads_key])
         end
         exit_content_creation = true
       end
       #TODO: Implement timeout for this
    end
  end
end
