class UsersController < ApplicationController
  layout :users_layout
  before_filter :setup_cart, :except => :empty_cart
  before_filter :set_initial_category
  skip_before_filter :check_authentication, :only => [ :login, :logout, :forgot_password, :reset ]
  skip_before_filter :check_authorization, :only => [ :login, :logout, :forgot_password, :reset ]
  skip_before_filter :check_website_open_status, :only => [ :login, :logout ]

  filter_parameter_logging :password, :password_confirmation

  def index
    @total_orders = Order.count
  end

  def complete_login
    if xml_request?
      render :file => 'users/login.rxml', :layout => false, :use_full_path => true
    else
      if session[:intended_action]
        redirect_to :action => session[:intended_action],
                    :controller => session[:intended_controller],
                    :params => session[:params]
      else
        redirect_to :action => "index",
                    :controller => "catalogue"
      end
    end
  end

  def login
    if request.post?
      session[:user_id] = nil
      session[:user_email] = nil
    end
    if request.post? and params["login.x"]
      user = User.authenticate(params[:login_user][:login_email], params[:login_user][:login_password])
      if user
        info("user_id: #{user.id} authenticated")
        session[:user_id] = user.id
        session[:user_email] = user.email
        complete_login
      else
        warn("invalid e-mail/password")
        flash[:notice] = t(:invalid_email_password)
        xml_error("LoginError", flash[:notice], "") if xml_request?
      end
    elsif request.post? and params["create.x"]
      @user = User.new(params[:user])
      @user.dvm_id = session[:dvm_id] if session[:dvm_id]
      if @user.save
        info("user_id: #{@user.id} created")
        session[:user_id] = @user.id
        session[:user_email] = @user.email
        complete_login
        #TODO: Validate the line below...
        @user = User.new
      else
        flash[:notice] = t(:problem_with_registration)
        error("user_id: #{@user.id} couldn't be saved")
        if xml_request?
          full_error = ""
          for error in @user.errors
            full_error = "#{full_error}#{error[0].humanize} #{error[1]}\n\n"
          end
          xml_error("CreateError", full_error)
        end
      end
    elsif not request.post? and xml_request?
      xml_error("RedirectLogin", "You need to login")
    end
  end

  def logout
    info("user_id: #{session[:user_id]} logout")
    reset_session
    session[:user_id] = nil
    session[:cart] = Cart.new
    redirect_to(:controller => "catalogue", :action => "index", :protocol => 'http://') unless xml_request?
  end  

  def destroy
    if request.post?
      user = User.find(params[:id])
      begin
        user.safe_delete
        flash[:notice] = "User #{user.email} deleted"
      rescue Exception => e
        flash[:notice] = e.message
      end
    end
    redirect_to(:action => :list)
  end

  def list
    @all_users = User.find(:all)
  end
  
  def order_history
    @filter_by_brand = true if params[:by_brand]
    @users = User.find(:all)
    respond_to do |accepts|
      accepts.html
      accepts.xml
    end
  end
  
  def sync_google_analytics_ecommerce
    @my_orders = Order.find(:all, :conditions => "complete = 1 AND sent_to_analytics is NULL")
    info("Found total #{@my_orders.length} orders to sync")
  end

  def forgot_password
    if request.post?
      user = User.find_by_email(params[:user][:email])
      if user
        user.create_reset_code(request.host)
        flash[:notice] = t(:password_reminder_email)
      else
        flash[:notice] = t(:user_does_not_exist)
        error("User does not exist")
      end
    end
  end

  def reset
    flash[:notice] = nil
    @user = User.find_by_reset_password_code(params[:id])
    if @user &&  @user.reset_password_code_until && Time.now < @user.reset_password_code_until
      debug("#{@user.reset_password_code_until} - #{Time.now}")
      if request.post?
        # don't do update_attributes(params[:user]) else user can change email address
        if @user.update_attributes(:password => params[:user][:password], :password_confirmation => params[:user][:password_confirmation])
          @user.delete_reset_code
          message = "#{t(:password_reset_msg_1)} #{@user.email}"
          info(message)
          flash[:notice] = message
          redirect_to :controller => "catalogue"
          return true
        else
          render :action => :reset
          return true
        end
      end
    else
      flash[:notice] = t(:Reset_code_expired)
      error("Reset code expired")
      redirect_to :action => :forgot_password
      return true
    end
  end

  protected
   
  def users_layout
    # TODO: Rubyfy next statement
    if ["login","forgot_password","reset"].include?(action_name)
      @store_layout
    else
      @store_admin_layout 
    end
  end
end
