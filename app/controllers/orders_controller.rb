require 'fastercsv'

class OrdersController < ApplicationController
  layout :store_admin_layout
  
  def who_bought
    @product = Product.find(params[:id], :conditions => @brand_filter)
    debug(@product.to_s)
    debug(@product.product_formats.inspect)
    @orders = @product.orders
    debug(@orders.inspect)
    @pages, @orders_pages = paginate_collection(:collection => @orders)
    respond_to do |accepts|
      accepts.html
      accepts.xml
    end
  end
  
  def audio_watermark_payments
    if request.post?
      out_rows = []
      info "Processing Audio Watermark Payments"
      aws = MediaWatermark.find_all_by_used(1, :order => "line_item_id")
      last_usd_ex_rate = params[:usd_ex_rate].to_f
      last_eur_ex_rate = params[:eur_ex_rate].to_f
      last_isk_ex_rate = params[:isk_ex_rate].to_f
      last_line_item_id = 0
      grand_total = 0.0
      for aw in aws
        next if last_line_item_id == aw.line_item_id
        next if aw.line_item.order.paypal_payment_status != "Completed"
        last_line_item_id = aw.line_item_id
        exchange_rate = 1.0
        if aw.line_item.currency_code != "GBP"
          if aw.line_item.order.paypal_exchange_rate
            exchange_rate = aw.line_item.order.paypal_exchange_rate
            if aw.line_item.currency_code == "USD"
              last_usd_ex_rate = exchange_rate
            elsif aw.line_item.currency_code == "EUR"
              last_eur_ex_rate = exchange_rate
            elsif aw.line_item.currency_code == "ISK"
              last_isk_ex_rate = exchange_rate
            else
              error "ERROR NO CURRENCY CODE"
            end
          else
            #puts "warning no currency rate"
            if aw.line_item.currency_code == "USD"
              exchange_rate = last_usd_ex_rate
            elsif aw.line_item.currency_code == "EUR"
              exchange_rate = last_eur_ex_rate
            elsif aw.line_item.currency_code == "ISK"
              exchange_rate = last_isk_ex_rate
            else
              error "ERROR NO CURRENCY CODE"
            end
          end
        end
        out_rows << ["#{aw.updated_at.strftime("%Y-%m")}",aw.line_item.order.id,aw.line_item.id,aw.line_item.currency_code,exchange_rate,aw.line_item.total_price,aw.line_item.total_price*exchange_rate]
        grand_total += aw.line_item.total_price*exchange_rate
      end
      info "Grand total #{grand_total}"
      out_rows_s = out_rows.sort {|a,b| a[0]<=>b[0]}
      csv_string = FasterCSV.generate do |csv|
        csv << ["Date","Order Id","LineItem Id","Currency Code","Exchange Rate","Price in Currency","Price in GBP"]
        for row in out_rows_s
    	  csv << row
  	    end
      end
      send_data csv_string, :filename => "audio_watermark_payments_#{Time.new.strftime("%d%m%y_%H%M%S")}.csv", :type => 'application/csv'    
    end
  end

  def h264_payments
    out_rows = []
    short_download_count_by_month = Hash.new
    long_download_count_by_month = Hash.new
    orders = Order.find_all_by_complete(1)
    for order in orders
      for line_item in order.line_items
        if line_item.product.duration > (12*60)
          unless long_download_count_by_month[order.created_at.strftime("%Y-%m")]
            long_download_count_by_month[order.created_at.strftime("%Y-%m")] = 0
          end
          long_download_count_by_month[order.created_at.strftime("%Y-%m")] += 1
        else
          unless short_download_count_by_month[order.created_at.strftime("%Y-%m")]
            short_download_count_by_month[order.created_at.strftime("%Y-%m")] = 0
          end
          short_download_count_by_month[order.created_at.strftime("%Y-%m")] += 1
        end
      end
    end 
    s_short_download_count_by_month = short_download_count_by_month.sort {|a,b| a[0]<=>b[0]}
    s_long_download_count_by_month = long_download_count_by_month.sort {|a,b| a[0]<=>b[0]}
    info "short downloads totals"
    out_rows << ["Short Dls","",""]
    out_rows << ["Date Month","Total Count","Short downloads price"]
    s_short_download_count_by_month.each do |key, value|
      out_rows << ["#{key}",value,0.0]
    end
    out_rows << ["","",""]
    info "long downloads totals"
    out_rows << ["Long Dls","",""]
    out_rows << ["Date Month","Total Count","Total Price ($0.02)"]
    s_long_download_count_by_month.each do |key, value|
      out_rows << ["#{key}",value,value*0.02]
    end
    csv_string = FasterCSV.generate do |csv|
      for row in out_rows
      	csv << row
  	  end
    end
    send_data csv_string, :filename => "h264_payments_#{Time.new.strftime("%d%m%y_%H%M%S")}.csv", :type => 'application/csv'        
  end

  def add_dvm_brands_to_paypal_csv
    if request.post?
      out_rows = []
      FasterCSV.parse(params[:csv_data].read) do |row|
	error = false
    #        debug(row.inspect)
        debug("row 19 #{row[19]}")
        unless row[33]=="" or row[33]==nil or row[33]==0 or row[33]=="Invoice Number" or row[33]==" Invoice Number"
	  debug("ROW33: #{row[33]}")
          order = Order.find(row[33].to_i)
          if order
            if row[19]=="" or row[19]==nil
              row[19]="#{order.line_items[0].product.brand.name}"
            end
	    if order.country_code
	        row[44]=order.country_code
	    end
            if order.dvm
              if order.dvm.user.email == "admin" or order.dvm.user.email == "dave" or order.dvm.user.email == "robert" or order.dvm.user.email.include?("@streamburst.tv")
                row[48]="streamburst_dvm"
              else
                row[48]=order.dvm.user.email
              end
            else
              row[48]="streamburst_website"
            end
            debug("new row 19 #{row[19]}")
          else
            error("CANT FIND INVOICE ID")
            row[19]="CANT FIND ORDER"
            error = true
          end
  	    else
          error("CANT FIND INVOICE ID")
          row[19]="CANT FIND INVOICE ID"
          error = true
        end
        out_rows << row
        unless error
          order.line_items.each do |line_item|
            line_item_row = []
            0..53.times {line_item_row << ""}
            line_item_row[3] = row[3]
            line_item_row[4] = row[4]
            line_item_row[33] = order.id
            line_item_row[19]="#{line_item.product.brand.name}"
            line_item_row[49]="#{line_item.product.title}"
            line_item_row[50]="#{line_item.product.categories[0].name}" if line_item.product.categories.length>0
            line_item_row[51]="#{line_item.price_real_gbp}"
            line_item_row[52]="#{line_item.price_real_gbp/order.total_price_real_gbp}"
            out_rows << line_item_row
          end
        end
      end
      
      csv_string = FasterCSV.generate do |csv|
        for row in out_rows
    	    csv << row
        end
      end
      debug(params[:csv_data].inspect)
      send_data csv_string, :filename => "fixed_for_dvm_data_#{params[:csv_data].original_filename}", :type => 'application/csv'
    end
  end

  def list
    @order_pages, @orders = paginate :orders, :per_page => 7
    respond_to do |accepts|
      accepts.html 
      accepts.xml
    end
  end

  def show
    @order = Order.find(params[:id])
    @line_items  = @order.line_items
    respond_to do |accepts|
      accepts.html 
      accepts.xml
    end
  end
end
