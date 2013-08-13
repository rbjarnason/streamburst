require 'paypal'
require 'payment_data'

PAYFLOW_API_USERNAME = "streamburst"
#PAYFLOW_API_USERNAME = "robertbjarnason"
PAYFLOW_API_PASSWORD = "Str3am3urst"

#PAYPAL_PRO_API_USERNAME = "dave_api1.streamburst.co.uk"
#PAYPAL_PRO_API_PASSWORD = "CRHHASBG34ETFMCW"

ActiveMerchant::Billing::Base.mode = :test if RAILS_ENV == "development"
ActiveMerchant::Billing::Base.mode = :production if RAILS_ENV == "production"

class CheckoutController < ApplicationController
  layout :store_layout
  before_filter :setup_cart, :except => :empty_cart
  before_filter :set_initial_category
  
  skip_before_filter :check_authentication, :only => [:paypal_ipn, :google_checkout_results]  
  skip_before_filter :check_authorization, :only => [:paypal_ipn, :google_checkout_results]
  skip_before_filter :redirect_to_ssl, :only => [:paypal_ipn, :google_checkout_results]

  filter_parameter_logging :security_code, :number, :start_year, :expiry_year, :start_month, :expiry_month, :issue

  def index
    if session[:order_id] && params[:discount_voucher] && params[:line_item]
      @order = Order.find(session[:order_id])
      voucher = DiscountVoucher.find_by_token(params[:discount_voucher])
      if voucher && voucher.used == false
        @order.add_discount_voucher(params[:line_item], voucher.id)
        @order.recalculate_total_price_and_save
        flash[:notice] = nil
      elsif voucher && voucher.used == true
        flash[:notice] = t(:discount_code_already_used)
      else
        flash[:notice] = t(:discount_code_not_found)
      end
    elsif @cart.items.empty? and not params[:parent_product_id]
      redirect_to_index(t(:cart_empty))
      return false
    else
      @order = Order.new
      @order.import_user_data(session[:user_id])
      if params[:parent_product_id]
        @cart  = Cart.new
        session[:cart] = @cart
        product = Product.find(params[:parent_product_id])
        @cart.add_product(product, @brand.id, @currency_code, session[:cart_show_all_brands], logger)
      end
      @order.add_line_items_from_cart(@cart)
      if @order.is_multi_brand?(@brand.id) and not @brand.global_brand_access and not xml_request?
        if @session_on
          myurl = url_for(params.merge({:host => "streamburst.tv#{RAILS_ENV=="production" ? "" : ":3000"}",
                                        :controller => "checkout",
                                        :_session_id => session.session_id
                             }))
        else
          myurl = url_for(params.merge({:host => "streamburst.tv#{RAILS_ENV=="production" ? "" : ":3000"}",
                                        :controller => "checkout"
                             }))
        end
        debug(myurl)
        redirect_to myurl
        return false
      end
      @order.status = "pre-pending"
      @order.country_code = @country_code
      @order.currency_code = @currency_code
      @order.locale = I18n.locale.to_s if @brand.filter_by_locale
      if session[:dvm_id]
        dvm = Dvm.find(session[:dvm_id])
        @order.dvm_id = dvm.id
        @order.affiliate_percent = dvm.dvm_template.affiliate_percent if dvm.dvm_template
      end
      if @order.save
        info("Order Saved: #{@order.inspect}")
        session[:order_id] = @order.id
      else
        error("Order couldn't be saved")
        notify_administrators("Order Save Failed", "Order Save failed for user: #{session[:user_id]} and Order: #{(@order == nil ? -1 : @order.id)}")        
        redirect_to_index(t(:problem_saving_order))
        return false
      end
    end
    setup_payflow_express_checkout if xml_request? and @order.total_price > 0.0

    respond_to do |accepts|
      accepts.html
      accepts.xml { render :file => 'checkout/index.rxml', :layout => false, :use_full_path => true }
    end
  end

  # Free downloads
  def complete
    @order = Order.find(params[:id])
    unless @order.user_id == session[:user_id]
      redirect_to_index(t(:this_is_not_your_order))
      return true
    end   
    if @order.total_price > 0
      redirect_to_index(t(:problem_with_order))
      return true
    end
    @cart = Cart.new
    session[:cart] = @cart
    debug(@order.email)
    session[:order_id] = nil
    @complete = true
    @order.complete = true
    @order.save
    @order.send_confirmation_email(request.host, @brand)
    info("Send email for order: #{@order.id}")
    respond_to do |accepts|
      accepts.html
      accepts.xml { render :file => 'checkout/complete.rxml', :layout => false, :use_full_path => true }
    end
  end

  # PAYPAL STANDARD WEB PAYMENTS
  def paypal_complete
    #initialize by passing the transaction id we get from paypal
    #params["tx"] = params["txn_id"] if params["txn_id"]
    info("Checking pdt for tx id: #{params["tx"]}")
    begin
      pdt = PaymentData::PaymentData.new(params["tx"])
      info(pdt.inspect)
      @cart = Cart.new
      session[:cart] = @cart
   
      if pdt.acknowledge
        @order = Order.find(pdt.invoice)
        unless @order.user_id == session[:user_id]
          redirect_to_index(t(:this_is_not_your_order))
        end
        #as paypal advises, at least check
        #   * the transaction is about the right amount, and 
        #   * the payment's recipient is correct
        if pdt.complete?
          info("Order: #{@order.id} is complete via PDT PayPal check")
          @complete = true
          @order.status = "pdt_complete"
          @order.complete = true
          @order.save
          session[:order_id] = nil
        else
          warn("Order: #{@order.id} is NOT complete")
          @complete = false
          @status = pdt.status
        end
      else
        error("PayPal PDT failed to acknowledge")
        raise
      end
    rescue => ex
      error("Order couldn't be verified")
      error(ex)
      error(ex.backtrace)
      @complete = false
      @status = ""   
      notify_administrators("Paypal Order Verification Failed", "For user: #{session[:user_id]} and Order: #{(@order == nil ? -1 : @order.id)}")
      #redirect_to_index("There was a problem verifying your order. System Administrators have been notified")
    end
  end

  def paypal_cancel
    @order = Order.find(params[:id])
    unless @order.user_id == session[:user_id]
      redirect_to_index(t(:this_is_not_your_order))
    end
    @order.cancelled_by_user = true
    @order.save
    session[:order_id] = nil
  end
  
  def paypal_ipn
    info("Request: #{request.raw_post}")
    if RAILS_ENV == "production"
      Paypal::Notification.ipn_url = "https://www.paypal.com/cgi-bin/webscr"
    else
      Paypal::Notification.ipn_url = "https://www.sandbox.paypal.com/cgi-bin/webscr"
    end

    notify = Paypal::Notification.new(request.raw_post)
    info("Notify #{notify.inspect}")
    begin
      order = Order.find(notify.invoice)
      if order.paypal_payment_status == "Completed"
        error("Trying to complete order #{order.id} second time with paypal IPN")
      else
        if notify.acknowledge
          if notify.complete?
            info("Payment successful for order: #{(order == nil ? -1 : order.id)}")
            order.complete_from_paypal(request.host, @brand, params)
          else
            warn("Paypal's notification not complete status: #{notify.status} for order: #{(order == nil ? -1 : order.id)}")
            order.status = notify.status
            order.save
            #TODO: Send email if payment denied
          end
        end
      end
    rescue => ex
      error(ex)
      error(ex.backtrace)    
      error("Failed to verify Paypal's notification for order: #{(order == nil ? -1 : order.id)}")
      notify_administrators("Paypal IPN Verification Failed", "For user: #{session[:user_id]} and Order: #{(order == nil ? -1 : order.id)}")
      order.status = 'failed' if order
    raise
    ensure
      order.save if order
    end
    render :nothing => true
  end

  def payment
    @order = Order.find(params[:id])
    @user = User.find(session[:user_id])
    unless @order.user_id == @user.id
      redirect_to_index(t(:this_is_not_your_order))
      return false
    end
    @months = (1..12).to_a
    @expiry_years = (Time.now.year..Time.now.year+7).to_a
    @start_from_years = (Time.now.year-7..Time.now.year).to_a
    @card_type_label = ["Visa", "MasterCard", "Amex", "Switch", "Solo", "Discover", "PayPal","Google"]
    @card_type_data = ["visa", "master", "americanexpress", "switch", "solo", "discover","paypal","google"]
  end

  # PAYFLOW DIRECT PAYMENT
  def payflow_payment
    @order = Order.find(params[:id])
    @user = User.find(session[:user_id])
    unless @order.user_id == @user.id
      redirect_to_index(t(:this_is_not_your_order))
      return false
    end

    creditcard = ActiveMerchant::Billing::CreditCard.new(
#     :number => '4111111111111111', #Visa paypal pro test
      :number => params[:card][:number],
      :month => params[:card][:expiry_month],
      :year => params[:card][:expiry_year],
      :start_month => params[:card][:start_month],
      :start_year => params[:card][:start_year],
      :first_name => @user.first_name,
      :last_name => @user.last_name,
      :type => params[:card][:card_type],
      :issue_number => params[:card][:issue_number],
      :verification_value  => params[:card][:security_code]
    )
   
   debug(params.inspect)
   debug(creditcard.inspect)
    
   if creditcard.valid?    
     setup_payflow_gateway(:payflow_uk)

     options = {
       :order_id => @order.id,
       :email => @user.email,
       :currency => @currency_code,
       :address => {} ,
       :description => 'Digital Downloads',
       :ip => request.remote_ip
     }      
     response = @@gateway.authorize(@order.total_price_in_cents, creditcard, options)
     info(response.inspect)
     if response.success?
       @@gateway.capture(@order.total_price_in_cents, response.authorization, options)
       info("Payflow Payment Success: " + response.message.to_s)
       @payment_complete = true
       @cart = Cart.new
       session[:cart] = @cart
       debug(@order.email)
       session[:order_id] = nil
       @complete = true
       @order.complete_from_payflow(request.host, @brand, response.params, response.test, response.authorization, response.success?, nil)
     else
       debug(response.params["result"])
       case response.params["result"].to_i
         when 11
           @payment_error = t(:payflow_error_1)
         when 12
           @payment_error = t(:payflow_error_2)
         when 23
           @payment_error = t(:payflow_error_2)
         when 24
           @payment_error = t(:payflow_error_2)
         when 25
           @payment_error = t(:payflow_error_2)
         when 30
           @payment_error = t(:payflow_error_3)
         when 50
           @payment_error = t(:payflow_error_2)
         when 104
           @payment_error = t(:payflow_error_1)
         when 109
           @payment_error = t(:payflow_error_1)
         when 114
           @payment_error = t(:payflow_error_2)
         when 115
           @payment_error = t(:payflow_error_5)
         when 150
           @payment_error = t(:payflow_error_1)
         else
           @payment_error = t(:payflow_error_6)
       end
       error("Payment not authorized: #{response.message.to_s}")
       flash[:notice] = @payment_error
       unless xml_request?
         redirect_to :action=>"payment", :id=>@order.id
         return false
       end
     end
   else 
     @payment_error = t(:payflow_error_7)
     for error in creditcard.errors
       @payment_error = "#{@payment_error} - #{error[0].humanize} #{error[1]}\n\n"
     end
     error("Card data invalid")
     flash[:notice] = @payment_error
     unless xml_request?
       redirect_to :action=>"payment", :id=>@order.id 
       return false
     end
   end
    respond_to do |accepts|
      accepts.html { render :action=> "paypal_complete"}
      accepts.xml { render :file => 'checkout/payflow_complete.rxml', :layout => false, :use_full_path => true }
    end
  end
    
  # PAYPAL PRO EXPRESS CHECKOUT
  def setup_payflow_express_checkout
    setup_payflow_gateway(:payflow_express_uk)
       # This would go in an action method for signing them into their account
    response = @@gateway.setup_purchase(
      @order.total_price_in_cents, # Also accepts Money objects
      :order_id => @order.id,
      :currency => @currency_code,
      :no_shipping => 1,
      :header_image => "https://streamburst.tv/images/streamburst.tv_paypal_banner.jpg",
      :return_url => url_for(:action => "payflow_express_success", :order_id => @order.id, :_session_id => session.session_id),
      :cancel_return_url => url_for(:action => "payflow_express_cancel", :order_id => @order.id, :_session_id => session.session_id),
      :description => "Payment for Streamburst content")
    info(response.inspect)
    if response.success?
      @payflow_express_button_url = @@gateway.redirect_url_for(response.params["token"])
      debug("payflow_express_button_url #{@payflow_express_button_url}")
    else
      error("Failed to verify Paypal's notification for order: #{(@order == nil ? -1 : @order.id)}")
      notify_administrators("setup_payflow_express_checkout", "For user: #{session[:user_id]} and Order: #{(@order == nil ? -1 : @order.id)}")    
    end
  end

  def payflow_express_success
    setup_payflow_gateway(:payflow_express_uk)
    response = @@gateway.details_for(params["token"])
    @complete = false
    if response.success?
      @order = Order.find(params['order_id'])
      @token = params["token"]
      if params["payerid"]
        @payerid = params["payerid"]
      else
        @payerid = params["PayerID"]
      end
      info(response.inspect)
    else
      error("Payment not authorized: #{response.message.to_s}")
      notify_administrators("Payment not authorized", "Payment not authorized for user: #{session[:user_id]} and Order: #{(@order == nil ? -1 : @order.id)}")        
      redirect_to_index(t(:problem_saving_order))
      return false
    end
  end

  def payflow_express_confirm
    setup_payflow_gateway(:payflow_express_uk)
    @order = Order.find(params['order_id'])
    response = @@gateway.purchase(
        @order.total_price_in_cents, 
        :express => true,
        :currency => @currency_code,
        :token => params["token"], 
        :payer_id => params["payerid"]
    )

    info(response.inspect)
    if response.success?
      @complete = true 
      @cart = Cart.new
      session[:cart] = @cart
      setup_cart
      @order.complete_from_payflow(request.host, @brand, response.params, response.test, response.authorization, response.success?, nil)
    else
      error("Payment not authorized: #{response.message.to_s}")
      notify_administrators("Payment not authorized", "Payment not authorized for user: #{session[:user_id]} and Order: #{(@order == nil ? -1 : @order.id)}")        
      redirect_to_index(t(:problem_saving_order))
      return false
    end
  end

  def payflow_express_cancel
    @order = Order.find(params[:order_id])
    unless @order.user_id == session[:user_id]
      redirect_to_index(t(:this_is_not_your_order))
    end
    @order.cancelled_by_user = true
    @order.save
    session[:order_id] = nil
    render :file => 'checkout/paypal_cancel.rhtml', :layout => true, :use_full_path => true 
  end

  def setup_payflow_gateway(gateway)
    @@pem_file = File.read(File.join(RAILS_ROOT, 'config', 'payflow.pem.txt'))
    error("Can't find pem file") unless @@pem_file
    @@gateway = ActiveMerchant::Billing::Base.gateway(gateway).new(
       :login => PAYFLOW_API_USERNAME,
       :password => PAYFLOW_API_PASSWORD,
       :pem => @@pem_file)
  end@currency_code

  # GOOGLE CHECKOUT
  class TaxTableFactory
    def effective_tax_tables_at(time)
      tax_free_table = Google4R::Checkout::TaxTable.new(false)
      tax_free_table.name = "default table"
      tax_free_table.create_rule do |rule|
        rule.area = Google4R::Checkout::WorldArea.new
        rule.rate = 0.0
      end
      return [tax_free_table]
    end
  end


  def google_checkout
    @order = Order.find(params[:id])
    unless @order.user_id == session[:user_id]
      redirect_to_index(t(:this_is_not_your_order))
      return false
    end
    Money.default_currency = @currency_code
    if RAILS_ENV=="production"
      configuration = { :merchant_id => '216156900312768', :merchant_key => '05cnCqyj3FFUK_1lDn1lYw', :use_sandbox => false}
    else
      configuration = { :merchant_id => '120301524436516', :merchant_key => 'olOfpU642lHW4r5uvnDHbg', :use_sandbox => true}
    end
    frontend = Google4R::Checkout::Frontend.new(configuration)
    frontend.tax_table_factory = TaxTableFactory.new

    checkout_command = frontend.create_checkout_command
    handler = frontend.create_notification_handler
    for line_item in @order.line_items
      if line_item.price > 0
        checkout_command.shopping_cart.create_item do |item|
          item.name = line_item.product.title
          item.description = truncate_line(line_item.product.description, 30)
          item.unit_price = Money.new(line_item.price_real_gbp*100, RAILS_ENV=="production" ? "GBP" : "USD")
          item.quantity = 1
          item.private_data = {:order_id => @order.id, :brand_name => @brand.name, :google_checkout_key => @order.google_checkout_key}
          item.digital_content do |dc|
            dc.url = RAILS_ENV=="production" ? "https://streamburst.tv/checkout/google_checkout_complete?key=#{@order.google_checkout_key}" : "http://app2.streamburst.net:3000/checkout/google_checkout_complete?key=#{@order.google_checkout_key}"
            dc.key = @order.google_checkout_key
          end
        end
      end
    end
    debug(checkout_command.inspect)
    response = checkout_command.send_to_google_checkout
    debug(response.inspect)
    redirect_to response.redirect_url
    return false
  end

  def google_checkout_complete
    @order = Order.find_by_google_checkout_key(params[:key])
    unless @order.user_id == session[:user_id]
      redirect_to_index(t(:this_is_not_your_order))
      return false
    end
    @complete = true
    @order.status = "google_checkout_complete"
    @order.complete = true
    @order.save
    info("Order: #{@order.id} is complete via Google Checkout")
    session[:order_id] = nil
  end

  def google_checkout_results
    google_order_number = params["google-order-number"]
    private_info = params["shopping-cart.items.item-1.merchant-private-item-data"]
    if google_order_number and private_info
      order_id = private_info[private_info.index("<order_id>")+"<order_id>".length...private_info.index("</order_id>")].to_i
      google_checkout_key = private_info[private_info.index("<google_checkout_key>")+"<google_checkout_key>".length...private_info.index("</google_checkout_key>")]
      @order = Order.find(order_id)
      if @order.google_checkout_key == google_checkout_key
        @order.google_order_number = google_order_number
        @order.save
      else
        error("Checkout key does not match order id")
      end
    end    
    if google_order_number and params["new-financial-order-state"] and params["new-financial-order-state"] == "CHARGEABLE"
      @order = Order.find_by_google_order_number(google_order_number)
      @order.complete_from_google_checkout(request.host, @brand, params) unless @order.paypal_payment_status and @order.paypal_payment_status == "Completed"
      info("Payment successful for order: #{(@order == nil ? -1 : @order.id)}")
    end
    for p in params
      info("#{p[0]} = #{p[1]}")
    end
    render :nothing => true
  end

  def isk_direct_payment
    @order = Order.find(params[:id])
    @user = User.find(session[:user_id])
    unless @order.user_id == @user.id
      redirect_to_index(t(:this_is_not_your_order))
      return false
    end
    
    if @order.currency_code == "ISK" and @brand.name=="LazyTown"      
      res = grapewire_payment(params[:card][:number], @order.total_price.to_i, 
                              "#{params[:card][:expiry_year]}#{params[:card][:expiry_month]}", 
                              params[:card][:security_code], @order.id, @user.email)
      res_code = res.code
    else
      res_code = 999
    end

    if res_code == 202
      @order.complete_from_isk(request.host, @brand)
    else
      @payment_error = "Greiðsla ekki samþykkt, vinsamlegast farðu yfir kortaupplýsingar og reyndu aftur. (#{res_code})"
      error("Payment not authorized: #{@payment_error}")
      flash[:notice] = @payment_error
      redirect_to :action=>"payment", :id=>@order.id
      return false
    end
    respond_to do |accepts|
      accepts.html { render :action=> "paypal_complete"}
    end
  end


  private

  def grapewire_payment(card, amount, expiration, cvc, refid, email)
    user_key = "12e0685c8148c56662a694b29c588a57"
    credit_card = "#{card[0..3]}-#{card[4..7]}-#{card[8..11]}-#{card[12..16]}"
    url = URI.parse("https://rest.grapewire.net/creditcart")
#    url = URI.parse("https://rest.grapewire.net/creditcart/#{card[0..3]}-#{card[4..7]}-#{card[8..11]}-#{card[12..16]}?amount=#{amount}&cvc=#{cvc}&expiration=#{expiration}&refid=#{refid}&email=#{email}&userkey=#{user_key}")
    request = Net::HTTP::Post.new(url.path)
    puts request.inspect
    request.set_form_data({'ref_id'=>refid, 'creditcard'=>credit_card, 'cvc'=>cvc, 'expiration'=>expiration, 'email'=>email, 'amount'=>amount, 'userkey'=>user_key}, ';')
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    htres = http.start {|http| http.request(request) }
    htres
  end

  def truncate_line(text, max_length)
    if text.length>max_length
      "#{text[0..max_length-1]}..."
    else
      text
    end
  end
end
