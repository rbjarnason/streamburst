class CatalogueController < ApplicationController
  layout :store_layout
  before_filter :setup_cart_filename
  before_filter :setup_cart, :except => :empty_cart
  before_filter :set_initial_category
  before_filter :check_demo_access, :except => [:access_to_demo, :geoblock, :website_closed, :coming_soon ] if RAILS_ENV["development"]

  skip_before_filter :check_website_open_status, :only =>  [ :website_closed, :coming_soon ]
  skip_before_filter :check_authentication, :only =>  [ :website_closed, :coming_soon ]
  skip_before_filter :check_authorization, :only =>  [ :website_closed, :coming_soon ]

  skip_before_filter :check_authentication
  skip_before_filter :check_authorization
  skip_before_filter :redirect_to_ssl

  DEMO_PASSWORD = "J32rhf7F"

  BJORK_WANDERLUST_BRAND_ID = 12
  BJORK_INCLUDED_COUNTRIES = ["GB","IS"]

  def setup_cart_filename
    if @brand.custom_products_list
      @cart_filename = "/layouts/#{@brand.to_home_param}/cart"
    else
      @cart_filename = 'shared/cart'
    end
  end

  def coming_soon    
    render :layout => false
    return false
  end

  def website_closed
    @brand_categories = []
    @website_closed = true
    render :layout => "streamburst"
  end

  def geoblock
    if params[:brand_id].to_i == BJORK_WANDERLUST_BRAND_ID
      if BJORK_INCLUDED_COUNTRIES.include?(@country_code)
        render :nothing => true, :status => 200
        return true
      else
      	info("Geoblocked!")
        render :nothing => true, :status => 403
        return true
      end
    end
    render :nothing => true, :status => 403
  end

  def home
    unless @brand.home_enabled
      redirect_to :action => "index"
      return false
    end
    redirect_to :action => "home" if params["_session_id"]
    if @brand.filter_by_locale and not cookies[:locale] and not params[:locale]
      redirect_to :action => "select_language"
      return false
    end
    @user = User.find(session[:user_id]) if session[:user_id]
  end

  def index
    if @brand.global_brand_access
      redirect_to :action => "brands"
      return false
    end

    session[:order_id] = nil #TODO: Find a better way, not do it each time on index
    session[:product_sponsor_bids] = nil
    if params[:category_id]
      begin                     
        @category = Category.find(params[:category_id])
      rescue
        error("Attempt to change to category that doesnt exist #{params[:id]}")
        redirect_to_index
      else
        session["category_id_#{@brand.id.to_s}".to_sym] = @category.id
        info("Changed to category #{@category.name}")
      end
    end

    @category = Category.find(session["category_id_#{@brand.id.to_s}".to_sym]) unless params[:category_id]
    @products = @category.products.find(:all,
                                        :order => "program_id", 
                                        :conditions => @brand_filter, 
                                        :page => { :current => params[:page], 
                                        :size => 80, 
                                        :first => 1,
                                        :manual_paging => true })
  
    @current_page =  (params[:page] ||= "1")
    info("Current page: #{@current_page}")
    
    if request.xhr?
      render :update, :layout => false do |page|
      	if params[:category_id]
      	  if @brand.custom_products_list
      	    page.replace_html("nav_tabs", :partial => "/layouts/#{@brand.to_home_param}/tabs")
      	  else
            page.replace_html("nav_tabs", :partial => 'shared/tabs')
      	  end
        end	  
      	if @brand.custom_products_list
          page.replace_html("forms", :partial => "/catalogue/products_list/#{@brand.to_home_param}_products_list")
        else
      	  page.replace_html("forms", :partial => "products_list")
        end
        page.select('div#notice').each { |div| div.hide }
      end
    end
  end

  def dvm_index
    session[:order_id] = nil #TODO: Find a better way, not do it each time on index
    session[:product_sponsor_bids] = nil

    dvm = Dvm.find(session[:dvm_id])
    if dvm.dvm_template.parent_product_id
      @parent_product = Product.find(dvm.dvm_template.parent_product_id)
      @products = @parent_product.child_products
    else
      @products = Product.find(:all,
                               :order => "program_id",
                               :conditions => @brand_filter)
    end
    respond_to do |accepts|
      accepts.xml { render :file => 'catalogue/dvm_index.rxml', :layout => false, :use_full_path => true }
    end
  end

  def brands
    if params[:brand_category_id]
      begin
        @brand_category = BrandCategory.find(params[:brand_category_id])
      rescue
        error("Attempt to change to brand category that doesnt exist #{params[:id]}")
        redirect_to_index
      else
        session[:brand_category_id] = @brand_category.id
        info("Changed to brand category #{@brand_category.name}")
      end
    end

    @brand_category = BrandCategory.find(session[:brand_category_id]) unless params[:brand_category_id]
    @brands = @brand_category.brands.find(:all,
                                        :order => "weight",
                                        :page => { :current => params[:page],
                                        :size => 15,
                                        :first => 1,
                                        :manual_paging => true })

    @current_page =  (params[:page] ||= "1")
    info("Current page: #{@current_page}")

    if request.xhr?
      render :update, :layout => false do |page|
        page.replace_html("nav_tabs", :partial => 'shared/brand_tabs') if params[:brand_category_id]
        page.replace_html("forms", :partial => "brands_list")
      end
    end
  end

  def dvm_brands
    @dvm = Dvm.find_by_token(params[:token])
    @dvm.exposure_count += 1
    begin
      @dvm.save
    rescue
      error("Couldn't save DVM counter")
    end
    session[:dvm_id] = @dvm.id
    @brands = @dvm.dvm_template.brands
    info("Dvm: #{@dvm.dvm_template.title} Affiliate: #{@dvm.user.email} #{@dvm.comment} Referer: #{request.env['HTTP_REFERER']} Agent: #{request.user_agent}")
    render :file => 'catalogue/dvm_brands.rxml', :layout => false, :use_full_path => true
  end

  def products
    @products = @brand.products(:order => "program_id")
    render :file => 'catalogue/index.rxml', :layout => false, :use_full_path => true
  end

  def page_cart
    session["cart_page_#{@brand.id.to_s}".to_sym] = params[:page].to_i if params[:page]
    setup_cart
    respond_to do |accepts|
      accepts.js
    end
  end

  def set_cart_all_brands
    if params[:show_all] == "true"
       session[:cart_show_all_brands] = true
    else
       session[:cart_show_all_brands] = nil
    end
    setup_cart
    respond_to do |accepts|
      accepts.js
    end
  end

  def add_to_cart
    begin                     
      @product = Product.find(params[:id])
    rescue
      error("Attempt to access invalid product #{params[:id]}")
      redirect_to_index(t(:Invalid_product))
    else
      add_results = @cart.add_product(@product, @brand.id, @currency_code, session[:cart_show_all_brands], logger)
      @current_item = add_results[0]
      found_page = add_results[1]
      if params[:sponsor_bid_id]
        @current_item.set_bid(params[:sponsor_bid_id].to_i, params[:sponsor_bid_amount].to_f) if params[:sponsor_bid_id]
      else
        @current_item.remove_bid
      end
      session[:cart] = @cart
      info("Added \"#{@product.title}\" to cart")
      if found_page == 0
        session["cart_page_#{@brand.id.to_s}".to_sym] = nil
      else
        session["cart_page_#{@brand.id.to_s}".to_sym] = found_page
      end
      setup_cart
    end  
    respond_to do |accepts|
      accepts.js
      accepts.xml { render :file => 'catalogue/cart.rxml', :layout => false, :use_full_path => true }
    end
    logger.debug(request.accepts)
  end

  def add_to_cart_with_sponsor
    @product = Product.find(params[:product_id])
    @sponsor_brands = @product.get_sponsor_brand_list_for_product(@currency_code, @territory_id, session)
    render :layout => false if request.xhr?
  end

  def remove_from_cart
    begin  
      @product = Product.find(params[:id])
    rescue
      error("Attempt to access invalid product #{params[:id]}")
      redirect_to_index(t(:Invalid_product))
    else 
      @cart.remove_product(@product)
      session[:cart] = @cart
      info("Removed \"#{@product.title}\" from cart")
      setup_cart
    end
    respond_to do |accepts|
      accepts.js
      accepts.xml { render :file => 'catalogue/cart.rxml', :layout => false, :use_full_path => true }
    end
  end

  def update_cart
    info("Updated cart")
    setup_cart

    respond_to do |accepts|
      accepts.xml { render :file => 'catalogue/cart.rxml', :layout => false, :use_full_path => true }
    end
  end

  def empty_cart
    @cart  = Cart.new
    session[:cart] = @cart
    info("Emptied cart")
    setup_cart

    respond_to do |accepts|
      accepts.js
      accepts.xml { render :file => 'catalogue/cart.rxml', :layout => false, :use_full_path => true }
    end
  end

  def check_demo_access
    session[:granted_demo_access] = true if xml_request?
    redirect_to :action => "access_to_demo" unless session[:granted_demo_access]
  end

  def access_to_demo
    if request.post?
      if params[:login][:password]==DEMO_PASSWORD
        session[:granted_demo_access] = true
        redirect_to :action => "home"
      else
        flash[:notice] = "invalid demo username or password"
      end
    end
  end
  
  def watch_now
    @watch_now_filename = params[:watch_now_filename]
    @watch_now_title = params[:title]
    @store_host = params[:store_host] unless params[:store_host] and params[:store_host] == request.host
    info("Title: #{@watch_now_title}")
    render :layout => false if request.xhr?
  end

  def instructions
    render :layout => false if request.xhr?
  end

  def select_language
    render :layout => false
  end

  private

  def should_play_welcome?
    if session[:seen_video_welcome] == nil and request.ssl? == false
      return true
    else
      return false
    end
  end

  def show_product
    @product = Product.find(params[:id], :conditions => @brand_filter)
  end
end
