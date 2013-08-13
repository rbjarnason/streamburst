class Order < ActiveRecord::Base
  has_many :line_items
  belongs_to :user
  belongs_to :dvm
  after_create :generate_downloads_key
  after_create :generate_google_checkout_key

  def add_line_items_from_cart(cart)
    total = 0
    check_has_audio = false
    check_has_video = false
    cart.items.each do |item|
      li = LineItem.from_cart_item(item)
      line_items << li
      total += li.price
      if item.product.audio_only
        check_has_audio = true
      elsif item.product.product_formats[0] and item.product.product_formats[0].format.format_type != 9
        check_has_video = true
      end
    end
    self.total_price = total
    self.has_audio = check_has_audio
    self.has_video = check_has_video
  end

  def expire_discount_vouchers
    for li in self.line_items
      if li.discount_voucher && li.discount_voucher.used == false
        li.discount_voucher.used = true
        li.discount_voucher.save
      end
    end
  end

  def recalculate_total_price_and_save
    total = 0
    for li in self.line_items
       total += li.price
    end
    self.total_price = total
    save
  end

  def total_price_in_cents
    (total_price * 100).to_i
  end

  def total_price_real_gbp
    total = 0
    for li in self.line_items
       total += li.price_real_gbp
    end
    total
  end

  def total_price_gbp
    total = 0
    for li in self.line_items
       total += li.price_gbp
    end
    total
  end

  def add_discount_voucher(line_item_id, discount_voucher_id)
    logger.debug("voucher #{line_item_id} #{discount_voucher_id}")
    for li in self.line_items
       logger.debug(li.inspect)
       if li.id == line_item_id.to_i
         li.discount_voucher_id = discount_voucher_id
         li.save
       end
    end
  end

  def import_user_data(user_id)
    user = User.find(user_id)
    self.user_id = user.id
    self.title = user.title
    self.first_name = user.first_name
    self.last_name = user.last_name
    self.email = user.email
    self.address_1 = user.address_1
    self.address_2 = user.address_2
    self.town = user.town
    self.county = user.county
    self.postcode = user.postcode
    self.country = user.country    
  end
  
  def send_confirmation_email(host, brand)
    begin
      localize_on_complete
      ready_email = OrderMailer.create_download_ready(self, host, brand, "ll")
      ready_email.set_content_type("text/html")
      OrderMailer.deliver(ready_email)
    rescue => ex
      logger.error(ex)
      logger.error(ex.backtrace)
      logger.error("Failed to send email for order: #{self.id} email: #{self.email}")
    end
  end

  def complete_from_google_checkout(host, brand, params)
    self.status = 'google_checkout_success'
    self.paypal_payment_status = "Completed"
    self.complete = true
    save
    logger.info("Send email for order: #{self.id}")
    send_confirmation_email(host, brand)
  end
  
  def complete_from_isk(host,brand)
    self.status = 'isk_success'
    self.paypal_payment_status = "Completed"
    self.complete = true
    save
    send_confirmation_email(host, brand)    
  end

  def complete_from_payflow(host, brand, params, test, authorization, success, fraud_review)
    self.status = 'payflow_success'
    begin
      self.payflow_message = params["message"]
      self.payflow_result = params["result"]
      self.payflow_partner = params["partner"]
      self.payflow_correlation_id = params["correlation_id"]
      self.payflow_pp_ref = params["pp_ref"]
      self.payflow_fee_amount = params["fee_amount"]
      self.payflow_pn_ref = params["pn_ref"]
      self.payflow_vendor = params["vendor"]
      self.payflow_auth_code = params["auth_code"]
      self.payflow_cv_result = params["cv_result"]
      self.payflow_test = test
      self.payflow_authorization = authorization
      self.payflow_success = success
      self.payflow_fraud_review = fraud_review
      self.paypal_payment_status = "Completed"
    rescue => ex
      logger.error(ex)
      logger.error(ex.backtrace)
    end    
    logger.info("Send email for order: #{self.id}")
    self.complete = true
    save
    send_confirmation_email(host, brand)
  end

  def complete_from_paypal(host, brand, params)
    self.status = 'ipn_success'
    begin
      self.paypal_txn_type = params["txn_type"]
      self.paypal_txn_id = params["txn_id"]
      self.paypal_receiver_id = params["receiver_id"]
      self.paypal_business = params["business"]
      self.paypal_receiver_email = params["receiver_email"]
      self.paypal_notify_version = params["notify_version"]
      self.paypal_verify_sign = params["verify_sign"]
      self.paypal_receipt_id = params["receipt_id"]

      self.paypal_first_name = params["first_name"]
      self.paypal_last_name = params["last_name"]
      self.paypal_residence_country = params["residence_country"]
      self.paypal_payer_id = params["payer_id"]
      self.paypal_payer_email = params["payer_email"]
      self.paypal_payer_status = params["payer_status"]

      self.paypal_address_status = params["address_status"]
      self.paypal_address_name = params["address_name"]
      self.paypal_address_street = params["address_street"]
      self.paypal_address_city = params["address_city"]
      self.paypal_address_zip = params["address_zip"]
      self.paypal_address_state = params["address_state"]
      self.paypal_address_country_code = params["address_country_code"]
      self.paypal_address_country = params["address_country"]
      
      self.paypal_invoice = params["invoice"]
      self.paypal_num_cart_items = params["num_cart_items"]
      self.paypal_payment_status = params["payment_status"]
      self.paypal_payment_date = params["payment_date"]
      self.paypal_payment_type = params["payment_type"]
      self.paypal_payment_gross = params["payment_gross"]
      self.paypal_payment_fee = params["payment_fee"]
      self.paypal_settle_currency = params["settle_currency"]
      self.paypal_exchange_rate = params["exchange_rate"]
      self.paypal_settle_amount = params["settle_amount"]
      self.paypal_mc_currency = params["mc_currency"]
      self.paypal_mc_shipping = params["mc_shipping"]
      self.paypal_mc_fee = params["mc_fee"]
      self.paypal_mc_handling = params["mc_handling"]
      self.paypal_mc_gross = params["mc_gross"]
      self.paypal_tax = params["tax"]
    rescue => ex
      logger.error(ex)
      logger.error(ex.backtrace)
    end    
    logger.info("Send email for order: #{self.id}")
    self.complete = true
    save
    send_confirmation_email(host, brand)
  end

  def is_multi_brand?(brand_id)
    for li in self.line_items
      if li.product.brand.id != brand_id
        return true
      end
    end
    return false
  end

  def localize_on_complete
    I18n.locale = self.locale if self.locale
  end

  private
  
  def random_md5_sum
    md5 = Digest::MD5::new
    now = Time::now
    md5.update(now.to_s)
    md5.update(String(now.usec))
    md5.update(String(rand(0)))
    md5.update(String($$))
    md5.update("trebor")
    md5.hexdigest
  end

  def generate_google_checkout_key
    retrycount = 0
    begin
      self.google_checkout_key = random_md5_sum.to_s
      self.save
    rescue
      if(retrycount < 10)
        retrycount+=1
        retry
      else
        logger.error("ERROR Could not save order")
        admin_email = AdminMailer.create_critical_error("Google Checkout key couldn't be created", "no")
        AdminMailer.deliver(admin_email)
      end
    end
  end
  
  def generate_downloads_key 
    logger.debug("GENERATING DOWNLOADS KEY")
    retrycount = 0
    begin
      self.downloads_key = random_md5_sum.to_s
      self.save
    rescue
      if(retrycount < 10)
        retrycount+=1
        retry
      else
        logger.error("ERROR Could not save order")
        admin_email = AdminMailer.create_critical_error("Download key couldn't be created", "no")
        AdminMailer.deliver(admin_email)
      end
    end
    logger.debug("DONE GENERATING DOWNLOADS KEY")
  end 
end
