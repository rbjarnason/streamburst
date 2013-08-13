require 'geoip'
require 'cgi/session'

class ApplicationController < ActionController::Base
  session :cookie_only => false
  session :off, :if => proc { |request| Utility.robot?(request.user_agent) }
  session :session_key => '_session_id'

  before_filter :set_xml_status
  before_filter :setup_store_by_host
  before_filter :set_country
  before_filter :check_authentication,
                :check_authorization
  before_filter :check_website_open_status
  before_filter :redirect_to_ssl
  before_filter :configure_charsets
  before_filter :set_session_status
#  before_filter :check_lazytown_geoblocking, :except => [:coming_soon]

#  after_filter :set_xml_no_cache

  CART_ITEMS_PER_PAGE = 4 

  protected

  def check_lazytown_geoblocking
    if @brand.id == 18 and @country_code=="GB"
      redirect_to :controller => "catalogue", :action => "coming_soon"
      return false
    end
  end

  def set_locale
    if @brand.filter_by_locale
      if cookies[:locale] and not params[:locale]
        I18n.locale = cookies[:locale]
      elsif params[:locale]
        I18n.locale = params[:locale]
        cookies[:locale] = params[:locale]
      end
    end
  end

  class Utility
    def self.robot?(user_agent)
      user_agent =~ /(Baidu|msnbot|ia_archiver|Googlebot|SiteUptime|Slurp|WordPress|ZIBB|ZyBorg)/i
    end
 
    def self.ie6?(user_agent)
      user_agent =~ /(MSIE 6.0|msie60)/i
    end
  end

  def set_session_status
    if Utility.robot?(request.user_agent)
      warn("Disabling session user-agent: #{request.user_agent}")
    else
      @session_on = true
      debug("Sessions enabled")
    end
  end

  #TODO: Try to remove workaround for flash 8
  def set_xml_status
    if params[:xml_request]
      request.env["CONTENT_TYPE"] = "text/xml"
      request.env["HTTP_ACCEPT"] = "application/xml"
      @xml_request_enabled = true
    end
  end
  
  def set_xml_no_cache
    response.headers["Cache-Control"] = "no-cache, must-revalidate"
    if Utility.ie6?(request.user_agent)
      response.headers["Pragma"] = "public"
    else
      response.headers["Pragma"] = "no-cache"
    end
#    @response.headers["Pragma"] = "no-cache"
#    response.headers["Content-Type"] = "application/xml" if xml_request?
#    @response.headers["Content-Type"] = "application/xhtml+xml" if @xml_request_enabled
  end

  def check_website_open_status
    @streamburst_config = StreamburstConfig.find(:first)
    unless @streamburst_config.website_open or session[:user_email] == "admin"
      redirect_to :controller => "catalogue", :action => "website_closed"
      return false
    end
  end

  def store_layout
    @store_layout
  end

  def store_admin_layout
    @store_admin_layout
  end

  def set_session_domain
 #   ActionController::Cgi::DEFAULT_SESSION_OPTIONS.update( :session_domain => 'tld.com')
  end

  def get_cart_page(item_count)
    if item_count > 0
      page = (item_count.to_f/CART_ITEMS_PER_PAGE.to_f).ceil
      page += 1 if page == 0
    else
      page = 1
    end
    if session["cart_page_#{@brand.id.to_s}".to_sym] && session["cart_page_#{@brand.id.to_s}".to_sym] <= page
      session["cart_page_#{@brand.id.to_s}".to_sym]
    else
      page
    end
  end

  def setup_cart
    @cart = (session[:cart] ||= Cart.new)    
    if @brand.global_brand_access == true or session[:cart_show_all_brands] or xml_request?
      @cart_pages, @cart_items = paginate_collection @cart.items, :per_page => CART_ITEMS_PER_PAGE, :page => get_cart_page(@cart.items.length)
    else
      cart_brand = []
      for cart_item in @cart.items
        cart_brand << cart_item if cart_item.product.brand.id == @brand.id
      end
        @cart_pages, @cart_items = paginate_collection cart_brand, :per_page => CART_ITEMS_PER_PAGE, :page =>  get_cart_page(cart_brand.length)
      end
    #if no brand_specific page is found - go to the last page of the cart
    #if current brand specifc page is now further then the last page go to last page
  end

  def set_country
    @country_code = (session[:country_code] ||= GeoIP.new(GEOIP_FILE).country(my_remote_ip)[3]) 
    if GBP_COUNTRIES.include?(@country_code)   
      @currency_code = "GBP"
    elsif EUR_COUNTRIES.include?(@country_code)
      @currency_code = "EUR"
    elsif @brand.id == 18 and @country_code=="IS" and I18n.locale.to_s=="is"
      @currency_code = "ISK"
    else
      @currency_code = "USD"
    end
    #TODO: Find from db and cache in session
    @territory_id = 1
    #@currency_code = "EUR" #disable currency selection
    #@country_code = "US"
    info("Country code: #{@country_code} - Currency code: #{@currency_code} - Language: #{I18n.locale.to_s}")
    if params[:gad]
      info("Google Ad from: #{params[:gad]}")
    end
    if params[:fb_ad]
      info("Facebook Ad from: #{params[:fb_ad]}")
    end
  end
  
  def set_initial_category
    @this_controller = controller_name
    @this_action = action_name

    @categories = Category.find(:all, :order=>"weight")
    
    unless session["category_id_#{@brand.id.to_s}".to_sym]
      if @brand.start_category_id
        session["category_id_#{@brand.id.to_s}".to_sym] = @brand.start_category_id
      else
        session["category_id_#{@brand.id.to_s}".to_sym] = @categories[0].id
      end
    end
    
    if @brand.global_brand_access
      @brand_categories = BrandCategory.find(:all)
      unless session[:brand_category_id]
        all_brand = BrandCategory.find_by_name("All")
        session[:brand_category_id] = all_brand.id
      end
    end
  end

  def notify_administrators(subject, body)
    admin_email = AdminMailer.create_critical_error(subject, body)
    admin_email.set_content_type("text/html")
    AdminMailer.deliver(admin_email)
  end

  private

  def setup_store_by_host
    info("Incoming host: #{request.host}")
    #debug("Request: #{request.inspect}")
    @brand = nil
    begin
      unless params[:brand_id]
        host = Host.find_by_name(request.host)
        @brand = host.brands[0]
      else
        @brand = Brand.find(params[:brand_id])
      end
      if @brand
        set_locale
        @store_layout = @brand.layout_name
        @store_admin_layout = "streamburst_admin"
        unless @brand.global_brand_access
          unless @brand.filter_by_locale
            @brand_filter = "brand_id = #{@brand.id}"
          else
            @brand_filter = "brand_id = #{@brand.id} AND locale_filter = \"#{I18n.locale.to_s}\""
          end
        end
      else
        error("brand not found")
        return false
      end
    rescue
      error("host not found")
      return false
    end
  end

  def redirect_to_ssl
    redirect_to url_for(params.merge({:protocol => SSL_PROTOCOL})) unless (request.ssl? or local_request? or SSL_PROTOCOL == "http://")
  end
   
  def check_authentication
    user = User.find_by_id(session[:user_id])
    if user == nil
      if xml_request?
        xml_error("RedirectLogin", "Login Needed")
        debug("check_authentication login redirect")
        return false
      else
        session[:intended_action] = action_name
        session[:intended_controller] = controller_name
        session[:params] = params
        redirect_to(:controller => "users", :action => "login")
        return false
      end
    else
      session[:user_email] = user.email
      session[:user_is_dvm_affiliate] = user.has_role?("DVM Affiliate")
    end
  end

  def check_authorization
    if session[:user_id]
      user = User.find(session[:user_id])
      unless user.roles.detect{|role|
        role.rights.detect{|right|
          (right.action == action_name || right.action == "*") && right.controller == self.class.controller_path
          }
        }
        if xml_request?
          xml_error("RedirectSignup", "")
        else
          flash[:notice] = t(:not_authorized)
          error("authorization failed for user: #{session[:user_id]}")
          redirect_to(:controller => "users", :action => "login")
        end
        return false
      end
    else
      check_authentication
    end
  end

  def redirect_to_index(msg = nil)
    error("Redirect to index with: #{msg}")
    notify_administrators("Redirect to Index Error", "#{msg} for user: #{session[:user_id]}") unless msg == "Your cart is empty"
    if xml_request?
      if msg
        xml_error("RedirectRestart", msg)
      else
        warn("Redirecting without error message when in xml mode")
      end
    else
      flash[:notice] = msg if msg
      if @brand.global_brand_access == true
        redirect_to :controller => "catalogue", :action => :brands, :protocol => 'http://'
      else
        redirect_to :controller => "catalogue", :action => :index, :protocol => 'http://'
      end
    end
    return false
  end

  def xml_error(code, message, errors = nil)
    @xml_error_code = code
    @xml_error_message = message
    @xml_error_details = errors
    render :file => 'shared/error.rxml', :layout => false, :use_full_path => true
  end
  
  def configure_charsets
    if request.xhr?
      response.headers["Content-Type"] ||= "text/javascript; charset=UTF-8"
#    else
#      response.headers["Content-Type"] ||= "text/html; charset=iso-8859-1"
    end
  end
  
  def user_id
    if session[:user_id]
      session[:user_id]
    else
      -1
    end
  end

  def log_time
    t = Time.now
    "%02d/%02d %02d:%02d:%02d.%06d" % [t.day, t.month, t.hour, t.min, t.sec, t.usec]
  end

  def info(text)
    logger.info("cs_info %s %s %s %d %s %s: %s" % [log_time, params[:xml_request] ? "xml" : "web", my_remote_ip, user_id, controller_name, action_name, text])
  end

  def warn(text)
    logger.warn("cs_warn %s %s %s %d %s %s: %s" % [log_time, params[:xml_request] ? "xml" : "web", my_remote_ip, user_id, controller_name, action_name, text])
  end

  def error(text)
    logger.error("cs_error %s %s %s %d %s %s: %s" % [log_time, params[:xml_request] ? "xml" : "web", my_remote_ip, user_id, controller_name, action_name, text])
  end

  def debug(text)
    logger.debug("cs_debug %s %s %s %d %s %s: %s" % [log_time, params[:xml_request] ? "xml" : "web", my_remote_ip, user_id, controller_name, action_name, text])
  end
  
  def paginate_collection(collection, options = {})
    default_options = {:per_page => 10, :page => 1}
    options = default_options.merge options

    debug("Set page to #{options[:page]}")

    pages = Paginator.new self, collection.size, options[:per_page], options[:page]
    first = pages.current.offset
    last = [first + options[:per_page], collection.size].min
    slice = collection[first...last]
    return [pages, slice]
  end

  def xml_request?
    debug("Content Type: #{request.content_type}")
    debug("Accepts: #{request.accepts}")
    params[:xml_request] || request.content_type == "application/xml" || request.content_type == "text/xml" || request.accepts.to_s == "application/xml"
  end
  
  def my_remote_ip
    return request.env['HTTP_CLIENT_IP'] if request.env.include? 'HTTP_CLIENT_IP'

    if request.env.include? 'HTTP_X_FORWARDED_FOR' then
      remote_ips = request.env['HTTP_X_FORWARDED_FOR'].split(',').reject do |ip|
        ip.strip =~ /^unknown$|^(10|172\.(1[6-9]|2[0-9]|30|31)|192\.168)\./i
      end

      return remote_ips.first.strip unless remote_ips.empty?
    end

    request.env['REMOTE_ADDR']
  end
end
