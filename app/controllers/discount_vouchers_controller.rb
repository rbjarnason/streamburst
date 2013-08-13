class DiscountVouchersController < ApplicationController
  
  MAX_VOUCHERS_PER_RUN = 1000
      
  def create_voucher_range
    if request.post?
      counter = 0
      if params[:send_email] == "true"
        @mailing_list = params[:discount_voucher][:mailing_list].split(",")
        volume = @mailing_list.length
      else
        volume = params[:discount_voucher][:volume].to_i
      end
      debug(volume)
      run = true
      while counter < volume
        voucher = DiscountVoucher.new
        voucher.range_name = params[:discount_voucher][:range_name]
        voucher.product_id = params[:discount_voucher][:product_id]
        voucher.discount_gbp = params[:discount_voucher][:discount_gbp]
        voucher.discount_eur = params[:discount_voucher][:discount_eur]
        voucher.discount_usd = params[:discount_voucher][:discount_usd]
        voucher.token = create_token
        if voucher.save && params[:send_email] == "true"   
          begin
#            voucher_email = OrderMailer.create_isotv_free_wozniak(@mailing_list[counter], voucher.token)
            voucher_email = OrderMailer.create_isotv_free_film(@mailing_list[counter], voucher.token)
            OrderMailer.deliver(voucher_email)
            info("Sent email to #{@mailing_list[counter]} with code #{voucher.token}")
          rescue => ex
            logger.error(ex)
            logger.error(ex.backtrace)
          end
        end
        if counter >= MAX_VOUCHERS_PER_RUN 
          counter = volume
        end
        counter += 1
      end
    end
  end

  def get_range
    @range_name = params[:range_name]
    @vouchers = DiscountVoucher.find_all_by_range_name(@range_name)
    respond_to do |accepts|
      accepts.html
      accepts.xml
    end
  end
  
private

  def create_token
    validChars = ("A".."Z").to_a + ("0".."9").to_a
    length = validChars.size
    retry_attempts = 0
    begin
      token = ""
      1.upto(8) { |i| token << validChars[rand(length-1)] }
      raise if DiscountVoucher.find_by_token(token)
    rescue
      if retry_attempts < 5
        retry_attempts += 1
        retry
      else
        error("Couln't create token")
      end
    end
    token
  end
    
  def create
    @right = Right.new(params[:right])
    if @right.save
      flash[:notice] = 'Right was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

end
