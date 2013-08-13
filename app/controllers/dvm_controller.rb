class DvmController < ApplicationController
  include FileColumnHelper

  layout :dvm_layout

  before_filter :set_initial_category
  before_filter :setup_cart, :except => :empty_cart
  before_filter :setup_rights
  before_filter :check_signup_status, :except => [:click, :signup, :show_templates]
  skip_before_filter :check_authentication, :only => [:click, :preview, :show_templates, :facebook_app, :bebo_app, :home]
  skip_before_filter :check_authorization, :only => [:click, :preview, :show_templates, :facebook_app, :bebo_app, :home, :signup]

  before_filter :facebook_setup, :only => :set_active_facebook_dvm
  before_filter :facebook_web_setup, :only => :facebook_app 

#  before_filter :reject_unadded_users
#  before_filter :find_bebo_user
  before_filter :bebo_setup
  
  CLICK_TYPE_GET_DVM = 1
  CLICK_TYPE_INFO = 2
  CLICK_TYPE_FORMATS = 3
  CLICK_TYPE_PREVIEW = 4
  CLICK_TYPE_PHOTO_UP = 5
  CLICK_TYPE_PHOTO_DOWN = 6
  CLICK_TYPE_HELP_MAIN = 7
  CLICK_TYPE_HELP_BUY = 8

  AUTO_DEPLOY_DVM_TEMPLATE_ID = 13

  def home
  end
  
  def click
    case params[:type].to_i
      when CLICK_TYPE_GET_DVM
        dvm = Dvm.find_by_token(params[:token])
        dvm_template = dvm.dvm_template
        dvm_template.get_dvm_click_counter += 1
        dvm_template.save      
        info("Get DVM")
      when CLICK_TYPE_INFO
        info("Information")
      when CLICK_TYPE_FORMATS
        info("Media Formats")
      when CLICK_TYPE_PREVIEW
        info("Preview")
      when CLICK_TYPE_PHOTO_UP
        info("Photo Up")
      when CLICK_TYPE_PHOTO_DOWN
        info("Photo Down")
      when CLICK_TYPE_HELP_MAIN
        info("Help Main")
      when CLICK_TYPE_HELP_BUY
        info("Help Buy")
      else
        error("Unknown click type")
    end
    
    respond_to do |format|
      format.xml { head :ok }
    end
  end

  def bebo_setup
    if params[:fb_sig_network] and params[:fb_sig_network]=="Bebo"
      reject_unadded_users
      find_bebo_user
    end
  end

  def facebook_setup
    if session[:facebook_session] 
    #  ensure_application_is_installed_by_facebook_user
      ensure_authenticated_to_facebook
    else
      xml_error("ToggleFacebookError","You are not logged into Facebook.  Please make sure you have the Streamburst DVM Facebook application installed, if not you can install it from here http://apps.facebook.com/dvm_app\n\n If you are accessing My DVMs through Facebook please reload to make sure your Facebook session is still valid.")
      return false
    end
  end

  def facebook_web_setup
    ensure_application_is_installed_by_facebook_user
    ensure_authenticated_to_facebook
  end

  def index
    redirect_to :action => 'home'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def show_templates
    @dvm_templates_pages, @dvm_templates = paginate :dvm_templates, :per_page => 150, :conditions => "active = 1 AND public_access = 1", :order => "weight"
    respond_to do |accepts|
      accepts.xml { render :file => 'dvm/show_templates.rxml', :layout => false, :use_full_path => true }
    end    
  end

  def select_template
    @dvm = Dvm.new
    @dvm.user_id = session[:user_id]
    @dvm.dvm_template_id = params[:dvm_template_id]
    @dvm.exposure_count = 0
    @dvm.active = 1
    if @dvm.save
      for brand in @dvm.dvm_template.brands
        @dvm.brands << brand
      end
      set_default_fb_dvm if session[:facebook_session]
      set_default_bebo_dvm if params[:fb_sig_network] and params[:fb_sig_network]=="Bebo"
      @completed = true
    end
    respond_to do |accepts|
      accepts.xml { render :file => 'dvm/select_template.rxml', :layout => false, :use_full_path => true }
    end    
  end

  def show
    @dvm = Dvm.find(params[:id])
    return false unless dvm_access?(@dvm)
  end

  def preview
    @dvm = Dvm.find(params[:id])
#    return false unless @dvm.dvm_template.public_access
    @embed_js_enabled = params[:embed_js_enabled]
    filename = "dvm/preview.rhtml"
    render :file => filename, :layout => false, :use_full_path => true
  end

  def facebook_app
    session[:country_code] = nil
    if params[:fb_sig_user]
      test_user = User.find_by_facebook_fb_sig_user(params[:fb_sig_user])
      unless test_user
        new_user = User.new
        new_user.facebook_fb_sig_user = params[:fb_sig_user]
        new_user.email = "facebook_user_#{params[:fb_sig_user]}@streamburst.tv"
        new_user.first_name = "Facebook"      
        new_user.last_name = "User"
        new_user.facebook_auto_deployed = true
        new_user.save(false)
        create_and_deploy_new_dvm(new_user.id, AUTO_DEPLOY_DVM_TEMPLATE_ID)
        info("Auto-deployed to Facebook for user_id #{new_user.id} facebook_fb_sig_user #{params[:fb_sig_user]}")
      end
    end
    render :layout => false
  end

  def bebo_app
    session[:country_code] = nil
    if params[:fb_sig_user]
      test_user = User.find_by_bebo_fb_sig_user(params[:fb_sig_user])
      unless test_user
        new_user = User.new
        new_user.bebo_fb_sig_user = params[:fb_sig_user]
        new_user.email = "bebo_user_#{params[:fb_sig_user]}@streamburst.tv"
        new_user.first_name = "Bebo"      
        new_user.last_name = "User"
        new_user.bebo_auto_deployed = true
        new_user.save(false)
        create_and_deploy_new_dvm(new_user.id, AUTO_DEPLOY_DVM_TEMPLATE_ID)
        info("Auto-deployed to Bebo for user_id #{new_user.id} bebo_fb_sig_user #{params[:fb_sig_user]}")
      end
    end
    render :layout => false
  end

  def portal
    @user = User.find(session[:user_id])
    @dvms_pages, @dvms = paginate :dvms, :per_page => 250, :conditions => "user_id = #{@user.id} and active = 1"
    unless @user.fb_user_id || @user.fb_user_id != params[:fb_sig_user]
      @user.fb_user_id = params[:fb_sig_user]
      @user.save(false)
    end
    respond_to do |accepts|
      accepts.xml { render :file => 'dvm/portal.rxml', :layout => false, :use_full_path => true }
    end    
  end

  def set_active_facebook_dvm
    # Check facebook session expiry	  
    @dvm = Dvm.find(params[:dvm_id])
    if dvm_access?(@dvm)
      set_default_fb_dvm
    else
      error("dvm access error")
    end
    respond_to do |accepts|
      accepts.xml { render :file => 'dvm/set_active_facebook_dvm.rxml', :layout => false, :use_full_path => true }
    end    
  end

  def set_active_bebo_dvm
    # Check facebook session expiry   
    @dvm = Dvm.find(params[:dvm_id])
    if dvm_access?(@dvm)
      set_default_bebo_dvm
    else
      error("dvm access error")
    end
    respond_to do |accepts|
      accepts.xml { render :file => 'dvm/set_active_bebo_dvm.rxml', :layout => false, :use_full_path => true }
    end    
  end

  def signup
    if request.post?
      unless params[:dvm_signup][:paypal_email] == "useregemail"
        if params[:dvm_signup][:paypal_email] == "" or (params[:dvm_signup][:paypal_email] != params[:dvm_signup][:paypal_email_confirmation])
          xml_error("SignupError", "Please confirm your payment email address", "") if xml_request?
          return false
        end
      end
      @user = User.find(session[:user_id])
      if params[:dvm_signup][:paypal_email] == "useregemail"
        @user.paypal_email = @user.email
      else
        @user.paypal_email = params[:dvm_signup][:paypal_email]
      end
      @user.fb_user_id = params[:fb_sig_user] if params[:fb_sig_user]
      @user.save(false)
      role = Role.find_by_name("DVM Affiliate")
      @user.roles << role unless @has_dvm_role
      begin
        @user.send_dvm_affiliate_welcome_mail
      rescue
        error("Couldn't send affiliate welcome mail")
      end
      respond_to do |accepts|
        accepts.xml { render :file => 'dvm/signup.rxml', :layout => false, :use_full_path => true }
      end     
    end
  end

  def new
    @dvm = Dvm.new
    @dvm.dvm_template_id = session[:dvm_template_id]
    @brands = Brand.find(:all)
    @companies = Company.find(:all)
  end

  def create
    @companies = Company.find(:all)
    @dvm = Dvm.new(params[:dvm])
    if params[:set_brand_id]
      brand = Brand.find(params[:set_brand_id])
      @dvm.brands << brand
    end
    @dvm.user_id = session[:user_id]
    @dvm.dvm_template_id = session[:dvm_template_id]
    @dvm.exposure_count = 0
    @dvm.active = 1
    if @dvm.save
      for brand in @dvm.dvm_template.brands
        @dvm.brands << brand
      end
      flash[:notice] = 'Dvm was successfully created.'
      redirect_to :action => 'portal'
    else
      render :action => 'new'
    end
  end

  def edit
    @dvm = Dvm.find(params[:id])
    return false unless dvm_access?(@dvm)
    @brands = Brand.find(:all)
    @companies = Company.find(:all)
  end

  def add_brand
    if params[:set_brand_id] != ""
       brand = Brand.find(params[:set_brand_id])
       @dvm.brands << brand
    end
  end
  
  def add_host
  end
  
  def update
    @dvm = Dvm.find(params[:id])
    return false unless dvm_access?(@dvm)
    if @dvm.update_attributes(params[:dvm])
      flash[:notice] = 'Dvm was successfully updated.'
      redirect_to :action => 'show', :id => @dvm
    else
      render :action => 'edit'
    end
  end

  def deactivate
    dvm = Dvm.find(params[:dvm_id])
    if dvm_access?(dvm)
      dvm.active = 0
      dvm.save
    end
    respond_to do |accepts|
      accepts.xml { render :file => 'dvm/deactivate.rxml', :layout => false, :use_full_path => true }
    end    
  end

  def destroy_dvm_brand
    @dvm = Dvm.find(params[:id])
    return false unless dvm_access?(@dvm)
    @brand = Brand.find(params[:set_brand_id])
    @dvm.brands.delete(@brand)
    redirect_to :action => 'show', :id => params[:id]
  end
  
private
  def create_and_deploy_new_dvm(user_id, dvm_template_id)
    @dvm = Dvm.new
    @dvm.user_id = user_id
    @dvm.dvm_template_id = dvm_template_id
    @dvm.exposure_count = 0
    @dvm.active = 1
    if @dvm.save
      for brand in @dvm.dvm_template.brands
        @dvm.brands << brand
      end
      set_default_fb_dvm if session[:facebook_session]
      set_default_bebo_dvm if params[:fb_sig_network] and params[:fb_sig_network]=="Bebo"
      @completed = true
      info("Have created new DVM")
    else
      error("Couldn't save dvm")
    end
  end
  
  def set_default_fb_dvm
    begin
      profile_box = render_to_string(:partial => 'dvm/dvm_profile_fbml', :locals => { :uid => params[:fb_sig_user], :dvm => @dvm })
      debug(profile_box)
      @facebook_user = session[:facebook_session].user
      @facebook_user.profile_fbml = profile_box
      #debug("FBSESSION: #{fbsession.inspect}")
      #fbsession.profile_setFBML({:markup => profile_box, :uid => params[:fb_sig_user], :session_key => params[:fb_sig_session_key]})
      if session[:user_id]
        @user = User.find(session[:user_id])
        @user.active_facebook_dvm_id = @dvm.id
        @user.facebook_fb_sig_user = params[:fb_sig_user]
        @user.save(false)
      end
      if @dvm.dvm_template.feed_image
        if RAILS_ENV=="production"
          image_url = "http://streamburst.tv#{url_for_image_column(@dvm.dvm_template, "feed_image", :name => "widescreen")}"
        else
          image_url = "http://app2.streamburst.net:3000#{url_for_image_column(@dvm.dvm_template, "feed_image", :name => "widescreen")}"
        end
      else
        image_url = nil
      end
      if session[:facebook_session].user.sex == nil or session[:facebook_session].user.sex == ""
        hisher = "his/her"
      elsif session[:facebook_session].user.sex == "male"
        hisher = "his"
      elsif session[:facebook_session].user.sex == "female"
        hisher = "her"
      else
        hisher = "his/her"
      end
      #FacebookerPublisher.deliver_recommend_templatized_news_feed(session[:facebook_session].user, @dvm.dvm_template.title, image_url, @dvm.dvm_template.affiliate_percent, hisher)
    rescue => ex
      error("FB set_active_facebook_dvm")
      error(ex)
      error(ex.backtrace)      
      xml_error("ToggleFacebookError", "Facebook interface connection error, please try again later")
      return false
    end
  end

  def set_default_bebo_dvm
    begin
      profile_box = render_to_string(:partial => 'dvm/dvm_profile_snml', :locals => { :uid => params[:fb_sig_user], :dvm => @dvm })
      debug(profile_box)
      BeboProfile.set_SNML(:uid => params[:fb_sig_user], :markup => profile_box)
      info("Have set Bebo Profile DVM")
      if session[:user_id]
        @user = User.find(session[:user_id])
        @user.active_bebo_dvm_id = @dvm.id
        @user.bebo_fb_sig_user = params[:fb_sig_user]
        @user.save(false)
      end
    rescue => ex
      error("set_active_bebo_dvm")
      error(ex)
      error(ex.backtrace)      
      xml_error("ToggleBeboError", "Bebo interface connection error, please try again later")
      return false
    end
  end

  def setup_rights
    @user = User.find_by_id(session[:user_id])
    if @user
      @has_dvm_role = @user.has_role?("DVM Affiliate")
      @has_admin_role = @user.has_role?("Admin")
    end
  end
  
  def check_signup_status
    unless @has_dvm_role
      xml_error("SignupRedirect", "", "") if xml_request?
      return false
    end
  end

  def dvm_access?(dvm)
    if session[:user_id]
      @user = User.find(session[:user_id])
    else
      error("dvm access user not found")
      return false
    end

    if @has_admin_role or (@has_dvm_role and @user.id == dvm.user_id)
      return true
    else
      error("This is not your dvm")
      flash[:notice] = t(:not_your_dvm)
      redirect_to :action => 'portal'
      return false
    end      
  end

  def dvm_layout
    @store_layout
  end
end
