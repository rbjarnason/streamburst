#Robert, thanks for the stats. Is it possible to get the main items below on a weekly or monthly basis.
#Ideally, if we could show:
#1. titles
#2. total units (episodes/ total downloadable units)
#3. registered users
#4. paying customers
#5. orders made
#6. total customer revenue (from downloads)
 
#We can then extract a few interesting relationships, 
#e.g. revenues/title, registered users/title, orders/customer, 
#orders/title, revenues/order, revenues/customer, etc.
#And how they evolve over time.
# 
#We can use this to strengthen our projections and justify expected trends.

require 'gruff'

class WeeklyRevenueHolder
  attr_accessor :total_gbp
  attr_accessor :web_gbp
  attr_accessor :dvm_gbp
  
  def initialize
    self.total_gbp = self.web_gbp = self.dvm_gbp = 0.0
  end
#  def initialize(total_gbp, web_gbp, dvm_gbp)
#    self.total_gbp = total_gbp
#    self.web_gbp = web_gbp
#    self.dvm_gbp = dvm_gbp
#  end
end
  


class SystemMailer < ActionMailer::Base
  def order_confirmation(order)
    subject         'Order confirmation'
    recipients      order.customer.email_address_with_name
    from            ''
    content_type    'multipart/alternative'
    
    part :content_type => 'text/plain',
         :body => render_message('registration_notifier_plain', :order => order)

    part 'multipart/related' do |p|
      # This next line makes it all work
      p.content_type='text/html'

      p.part :content_type => 'text/html',
             :body => render_message('registration_notifier_html', :order => order)

      p.part :content_type => 'image/gif',
             :content_disposition => 'inline',
             :transfer_encoding => 'base64',
             :body => File.read("#{RAILS_ROOT}/public/images/logo.gif")
    end
  end

  def full_order_status(email, subject)
    @subject       = subject
    @recipients    = email
    @from          = 'admin@streamburst.tv'
    @sent_on    = Time.now
 
    setup_order_status 

    revenue_by_month_graph = Gruff::Line.new("500x375")
    revenue_by_month_graph.title = "Monthly Revenue"
    months_revenue = []
    months_labels = Hash.new
    label_counter = 0
    @revenue_by_month_count_s_minus_one = @revenue_by_month_count_s[0,@revenue_by_month_count_s.length-1]
    @revenue_by_month_count_s_minus_one.each do |key, value|
      months_labels[label_counter] = key
      label_counter += 1
      months_revenue << value
    end
    revenue_by_month_graph.data("Revenue", months_revenue)
    revenue_by_month_graph.labels = months_labels
    @body["revenue_by_month_content_id"] = "revenue_by_month_graph"

    revenue_by_week_graph = Gruff::Line.new("500x375")
    revenue_by_week_graph.title = "Weekly Revenue"
    total_revenue = []
    dvm_revenue = []
    web_revenue = []
    labels = Hash.new
    label_counter = 0
    total_counter = 0
    max_labels = 6 
    label_divider =  @revenue_by_week_count_s.length / max_labels
    puts "total #{@revenue_by_week_count_s.length}"
    puts "div label #{label_divider}"
    @revenue_by_week_count_s_minus_one = @revenue_by_week_count_s[0,@revenue_by_week_count_s.length-1]
    @revenue_by_week_count_s_minus_one.each do |key, value|
      if label_counter == 0 || label_counter > label_divider
        puts "setting label for #{key}"
        labels[total_counter] = key 
        label_counter = 1
      end
      label_counter += 1
      total_counter += 1
      total_revenue << value.total_gbp
      web_revenue << value.web_gbp
      dvm_revenue << value.dvm_gbp
    end
    revenue_by_week_graph.data("Total Revenue", total_revenue)
    revenue_by_week_graph.data("Web Revenue", web_revenue)
    revenue_by_week_graph.data("DVM Revenue", dvm_revenue)
    revenue_by_week_graph.labels = labels
    @body["revenue_by_week_content_id"] = "revenue_by_week_graph"

    revenues_by_brand_by_week_hash = Hash.new
    @revenue_by_brand_by_week.each do |brand_key_full, brand_weeks|
      brand_key = brand_key_full.gsub(" ","_")
      revenue_by_brand_by_week_graph = Gruff::Line.new("500x375")
      revenue_by_brand_by_week_graph.title = "#{brand_key_full} Weekly Revenue"
      total_revenue = []
      dvm_revenue = []
      web_revenue = []
      labels = Hash.new
      label_counter = 0
      total_counter = 0
      max_labels = 6 
      label_divider =  brand_weeks.length / max_labels
      puts "total #{brand_weeks.length}"
      puts "div label #{label_divider}"
      brand_weeks_minus_one = brand_weeks.sort {|a,b| a[0]<=>b[0]}[0,brand_weeks.length-1]
      brand_weeks_minus_one.each do |key, value|
        if label_counter == 0 || label_counter > label_divider
          puts "setting label for #{key}"
          labels[total_counter] = key 
          label_counter = 1
        end
        label_counter += 1
        total_counter += 1
        total_revenue << value.total_gbp
        web_revenue << value.web_gbp
        dvm_revenue << value.dvm_gbp
      end
      revenue_by_brand_by_week_graph.data("Total Revenue", total_revenue)
      revenue_by_brand_by_week_graph.data("Web Revenue", web_revenue)
      revenue_by_brand_by_week_graph.data("DVM Revenue", dvm_revenue)
      revenue_by_brand_by_week_graph.labels = labels
      @body["revenue_by_brand_by_week_content_id_"+brand_key] = "revenue_by_brand_by_week_graph_"+brand_key
      revenues_by_brand_by_week_hash[brand_key] = revenue_by_brand_by_week_graph
    end
  
    revenue_by_day_graph = Gruff::Line.new("500x375")
    revenue_by_day_graph.title = "Daily Revenue"
    revenue = []
    labels = Hash.new
    label_counter = 0
    total_counter = 0
    max_labels = 6 
    label_divider =  @revenue_by_day_count_s.length / max_labels
    @revenue_by_day_count_s_minus_one = @revenue_by_day_count_s[0,@revenue_by_day_count_s.length-1]
    @revenue_by_day_count_s_minus_one.each do |key, value|
      if label_counter == 0 || label_counter > label_divider
        puts "setting label for #{key}"
        labels[total_counter] = key 
        label_counter = 1
      end
      label_counter += 1
      total_counter += 1
      revenue << value
    end
    revenue_by_day_graph.data("Revenue", revenue)
    revenue_by_day_graph.labels = labels
    @body["revenue_by_day_content_id"] = "revenue_by_day_graph"

    revenue_by_brand_graph = Gruff::Pie.new("700x420")
    revenue_by_brand_graph.title = "Revenue by Brands"
    revenue_by_brand_graph.legend_font_size = 12
    revenue_by_brand_graph.marker_font_size = 12
    revenue_by_brand_graph.title_font_size = 14
    @revenue_by_brand_s.each do |key, value|
      revenue_by_brand_graph.data(key, [value/@total]) if value/@total > 0.01
    end
    @body["revenue_by_brand_content_id"] = "revenue_by_brand_graph"

    content_type    'multipart/alternative'
     
    part :content_type => 'text/plain',
         :body => render_message('full_order_status_plain', @body)
      
    part 'multipart/related' do |p|      
      p.part :content_type => 'text/html',
             :body => render_message('full_order_status_html', @body)
             
      p.part :content_type => 'image/gif',
             :body => revenue_by_month_graph.to_blob(fileformat='GIF'),
             :filename =>@body["revenue_by_month_content_id"]+'.gif',
             :transfer_encoding => 'base64',
             :headers => {'Content-Id' => @body["revenue_by_month_content_id"]}

      p.part :content_type => 'image/gif',
             :body => revenue_by_week_graph.to_blob(fileformat='GIF'),
             :filename =>@body["revenue_by_week_content_id"]+'.gif',
             :transfer_encoding => 'base64',
             :headers => {'Content-Id' => @body["revenue_by_week_content_id"]}

      p.part :content_type => 'image/gif',
             :body => revenue_by_day_graph.to_blob(fileformat='GIF'),
             :filename =>@body["revenue_by_day_content_id"]+'.gif',
             :transfer_encoding => 'base64',
             :headers => {'Content-Id' => @body["revenue_by_day_content_id"]}

      p.part :content_type => 'image/gif',
             :body => revenue_by_brand_graph.to_blob(fileformat='GIF'),
             :filename =>@body["revenue_by_brand_content_id"]+'.gif',
             :transfer_encoding => 'base64',
             :headers => {'Content-Id' => @body["revenue_by_brand_content_id"]}

      @revenue_by_brand_by_week.each do |brand_key_full, brand_weeks|
	      brand_key = brand_key_full.gsub(" ","_")
        p.part :content_type => 'image/gif',
               :body => revenues_by_brand_by_week_hash[brand_key].to_blob(fileformat='GIF'),
               :filename =>@body["revenue_by_brand_by_week_content_id_"+brand_key]+'.gif',
               :transfer_encoding => 'base64',
               :headers => {'Content-Id' => @body["revenue_by_brand_by_week_content_id_"+brand_key]}
      end
    end    
  end

  def payment_report(filename,subject,content)
    @subject       = subject
    @recipients    = "robert@decyphermedia.com,dave@streamburst.co.uk,robert@streamburst.co.uk,dave@decyphermedia.com,robert.lackey@sky.com"
    @from          = 'admin@streamburst.tv'
    @sent_on    = Time.now

    
    part :content_type => 'text/plain',
         :body => render_message('payment_report', @body)
	           
    attachment "text/csv" do |a|
      a.body = content
      a.filename = filename
    end
  end

private

  def setup_order_status
    @users = User.find(:all)

    @total = 0
    @cat_count = Hash.new()
    @brand_count = Hash.new()
    @order_count = 0
    @user_count = 0
    @unit_count = 0
    @total_registered_user = User.count
    @country_count = Hash.new() 
    @paypal_country_count = Hash.new()
    @order_by_week_count = Hash.new()
    @revenue_by_week_count = Hash.new()
    @revenue_by_day_count = Hash.new()
    @revenue_by_month_count = Hash.new()
    @revenue_by_brand = Hash.new()
    @revenue_by_brand_by_week = Hash.new()

    for user in @users
      next if user.id > 100 and RAILS_ENV=="development"
      total_user = 0
      @my_orders = Order.find_all_by_user_id(user.id, :conditions => "paypal_payment_status = \"Completed\"")
      next if @my_orders == nil || @my_orders.length == 0
      @user_count += 1
      puts "User Id: #{user.id}"
      for order in @my_orders
        #puts "Order Id: #{order.id}"
        if order.paypal_payment_status=="Completed" 
          @order_count += 1
          total_user += order.total_price_gbp 
          @total += order.total_price_gbp 

          unless @revenue_by_day_count[order.created_at.strftime("%Y-%m-%d")] 
            @revenue_by_day_count[order.created_at.strftime("%Y-%m-%d")] = 0.0
          end 
          @revenue_by_day_count[order.created_at.strftime("%Y-%m-%d")] += order.total_price_gbp 

          unless @order_by_week_count[order.created_at.strftime("%Y-%W")] 
            @order_by_week_count[order.created_at.strftime("%Y-%W")] = 0 
          end 
          @order_by_week_count[order.created_at.strftime("%Y-%W")] += 1 

          unless @revenue_by_week_count[order.created_at.strftime("%Y-%W")] 
            @revenue_by_week_count[order.created_at.strftime("%Y-%W")] = WeeklyRevenueHolder.new
          end 
          @revenue_by_week_count[order.created_at.strftime("%Y-%W")].total_gbp += order.total_price_gbp
          if order.dvm_id
            @revenue_by_week_count[order.created_at.strftime("%Y-%W")].dvm_gbp += order.total_price_gbp 
          else
            @revenue_by_week_count[order.created_at.strftime("%Y-%W")].web_gbp += order.total_price_gbp
          end

          unless @revenue_by_month_count[order.created_at.strftime("%Y-%m")] 
            @revenue_by_month_count[order.created_at.strftime("%Y-%m")] = 0.0 
          end 
          @revenue_by_month_count[order.created_at.strftime("%Y-%m")] += order.total_price_gbp 

          unless @country_count[order.country_code] 
            @country_count[order.country_code] = 0 
          end 
          @country_count[order.country_code] += 1 

          unless @paypal_country_count[order.paypal_residence_country] 
            @paypal_country_count[order.paypal_residence_country] = 0 
           end 
          @paypal_country_count[order.paypal_residence_country] += 1 

          for li in order.line_items 
            unless li.product == nil 
              category = li.product.categories[0] 
              unless @cat_count[category] 
                @cat_count[category] = 0
              end 
              @cat_count[category] += 1
              @unit_count += 1
              unless @brand_count[li.product.brand.name] 
                @brand_count[li.product.brand.name] = Hash.new() 
              end 
              
              unless @brand_count[li.product.brand.name][category] 
                 @brand_count[li.product.brand.name][category] = 0 
              end 
              @brand_count[li.product.brand.name][category] += 1 

              unless @revenue_by_brand[li.product.brand.name]
                 @revenue_by_brand[li.product.brand.name] = 0.0
              end
              @revenue_by_brand[li.product.brand.name] += li.price_gbp   

              unless @revenue_by_brand_by_week[li.product.brand.name]
                 @revenue_by_brand_by_week[li.product.brand.name] = Hash.new
              end

              unless @revenue_by_brand_by_week[li.product.brand.name][order.created_at.strftime("%Y-%W")] 
                @revenue_by_brand_by_week[li.product.brand.name][order.created_at.strftime("%Y-%W")] =  WeeklyRevenueHolder.new
              end 

              @revenue_by_brand_by_week[li.product.brand.name][order.created_at.strftime("%Y-%W")].total_gbp += li.price_gbp
              if order.dvm_id
                @revenue_by_brand_by_week[li.product.brand.name][order.created_at.strftime("%Y-%W")].dvm_gbp += li.price_gbp
              else
                @revenue_by_brand_by_week[li.product.brand.name][order.created_at.strftime("%Y-%W")].web_gbp += li.price_gbp
              end
            end 
          end
        end 
      end
    end
    @revenue_by_day_count_s = @revenue_by_day_count.sort {|a,b| a[0]<=>b[0]}
    @order_by_week_count_s = @order_by_week_count.sort {|a,b| a[0]<=>b[0]}
    @revenue_by_week_count_s = @revenue_by_week_count.sort {|a,b| a[0]<=>b[0]}
    @revenue_by_month_count_s =  @revenue_by_month_count.sort {|a,b| a[0]<=>b[0]}
    @revenue_by_brand_s = @revenue_by_brand.sort {|a,b| b[1]<=>a[1]}

    @body["total"] = @total
    @body["cat_count"] = @cat_count
    @body["brand_count"] = @brand_count
    @body["order_count"] = @order_count
    @body["user_count"] = @user_count
    @body["country_count"] = @country_count
    @body["total_registered_user"] = @total_registered_user
    @body["unit_count"] = @unit_count
    @body["paypal_country_count"] = @paypal_country_count
    @body["revenue_by_day_count"] = @revenue_by_day_count_s
    @body["order_by_week_count"] = @order_by_week_count_s
    @body["revenue_by_week_count"] = @revenue_by_week_count_s
    @body["revenue_by_month_count"] = @revenue_by_month_count_s
    @body["revenue_by_brand"] = @revenue_by_brand_s
    @body["revenue_by_brand_by_week"] = @revenue_by_brand_by_week
  end
end
