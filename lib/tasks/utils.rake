namespace :utils do
  desc "Reset watermork for product"
  task(:reset_watermark_for_product => :environment) do
    download_id = ENV['download_id'].to_i
    video_server_id = ENV['video_server_id'].to_i
    puts download_id
    puts video_server_id
    MediaWatermark.find(:all, :conditions=>"used=0 AND reserved=0 AND download_id = #{download_id} AND cache_video_server_id = #{video_server_id}").each do |w|
      dl = Download.find(w.download_id)
      w.reserved = true
      w.save
      ff = "/var/content/watermark_cache_production/#{dl.id}/#{w.id}/#{dl.file_name}.mp4"
      puts ff
      File.delete(ff)
      puts w.inspect
    end
  end

  desc "Show Buyers for Product"
  task(:show_buyers => :environment) do
    product_id = ENV['product_id'].to_i
    user_ids = Hash.new
    line_items = LineItem.find_all_by_product_id(product_id)
    total_bought = 0
    for line_item in line_items
      if line_item.order.paypal_payment_status and line_item.order.paypal_payment_status=="Completed"
        unless user_ids[line_item.order.user_id]
          user_ids[line_item.order.user_id] = 0
        end
        user_ids[line_item.order.user_id] += 1
        total_bought += 1
      end
    end
    for user_id in user_ids
      user = User.find(user_id[0])
      puts "#{user.email},#{user.first_name},#{user.last_name},#{user_id[1]}"
    end
    puts "TOTAL: #{total_bought}"
  end
  
  desc "Send Streamburst Newsletter"
  # rake utils:send_streamburst_newsletter RAILS_ENV=production newsletter_number=001
  # rake utils:send_streamburst_newsletter RAILS_ENV=production really_send_to_all=true newsletter_number=001
  task(:send_streamburst_newsletter => :environment) do
       if ENV['newsletter_number']
         newsletter_number = ENV['newsletter_number']
         puts "Sending Streamburst newsletter number #{newsletter_number}"
       else
         raise "usage: rake newsletter_number= # the number of the newsletter e.g. 001 or 002"
       end
       if ENV['really_send_to_all']=="true"
         users = User.find(:all)
       else
        users = User.find(:all) #("robert.bjarnason@gmail.com")
        dave_user = User.find_by_email("dave@decyphermedia.com")
        users << dave_user
      end
      for user in users
        begin
#            newsletter_email = OrderMailer.create_streamburst_newsletter(user, newsletter_number)
#            newsletter_email.set_content_type("text/html")
#            OrderMailer.deliver(newsletter_email)
        rescue
          puts "Send error for #{user.first_name} #{user.last_name}"
        end
        puts "Sent newsletter to #{user.first_name} #{user.last_name}"
      end
  end

  desc "Show timings"
  task(:show_timings => :environment) do
    timings = VideoPreparationTime.find(:all, :order => "video_server_id ASC, activity_type ASC, time DESC")
    for entry in timings
      puts "video_server: #{entry.video_server_id} activity_type: #{entry.activity_type} time: #{entry.time}"
    end
  end

  desc "Purge watermark cache for product"
  task(:purge_watermark_cache_for_product => :environment) do    
    Product.find(ENV['product_id']).product_formats.each do |product_format|
      @watermarks = MediaWatermark.find_all_by_used(0, :conditions => "reserved = 0 AND download_id = #{product_format.download.id} AND cache_video_server_id = #{ENV['video_server']}")
      @watermarks.each do |watermark|
        watermark.reload(:lock=>true) if ENV['doit']=="yes"
        watermark_file = "/var/content/watermark_cache_"+ENV['RAILS_ENV']+"/#{watermark.download_id}/#{watermark.id}/#{watermark.download.file_name}.mp4"
        puts "watermark id: #{watermark.id} product_id: #{watermark.product_id} download_id: #{watermark.download_id} used: #{watermark.used} reserved: #{watermark.reserved} cache_video_server_id: #{watermark.cache_video_server_id}"
        puts "delete #{watermark_file} exists: #{File.exist?(watermark_file)}"
        File.delete(watermark_file) if File.exist?(watermark_file) if ENV['doit']=="yes"
        watermark.reserved = 1 if ENV['doit']=="yes"
        watermark.save if ENV['doit']=="yes"
      end        
    end
  end
  
  desc "Import filesizes"
  task(:import_filesizes => :environment) do
    include ActionView::Helpers::DeliveryHelper
    for product in Product.find(:all)
      puts "processing #{product.id} - #{product.title}"
      if product.product_formats.length > 0
        for product_format in product.product_formats
           puts "product format: #{product_format.inspect}"
          size = get_file_size(product_format.download.file_name, product.company.id, product.brand.id, product_format.format.id, product.audio_only)
          puts "download file name: #{product_format.download.file_name} size: #{size}"
      	  download = product_format.download
      	  download.file_size_mb = size
      	  download.save
        end
      else
        puts "#{product.title} doesn't have any product formats"
      end
    end
  end

  desc "Find first users for DJU"
  task(:find_dju => :environment) do
      line_items = LineItem.find_all_by_product_id(53)
      puts line_items.inspect
      for li in line_items
        puts "Date #{li.order.created_at} Complete: #{li.order.status} email: #{li.order.user.email}"
      end
  end

  desc "Average Revenue per user by brand"
  task(:average_revenue_per_user_by_brand => :environment) do
    brands = []
    brands_user_counter = []
    brands_total_payments = []
    brands_update_user_count = []
    all_brands = Brand.find(:all)
    for brand in all_brands
      brands << brand
      brands_user_counter << 0
      brands_total_payments << 0.0
      brands_update_user_count << false
    end
     
    all_users = User.find(:all)
    
    for user in all_users
      next if user.id == 1 or user.id == 2 or user.id == 4 or user.id == 36
      for order in user.orders
        next unless order.paypal_payment_status == "Completed"
        for line_item in order.line_items
          count = 0
          for brand in brands
            #puts "#{brand.id} #{brands[count].id}"
            if line_item.product and brands[count].id == line_item.product.brand.id
             # puts "found item"
              brands_update_user_count[count] = true
              brands_total_payments[count] += line_item.price_gbp
            end
            count += 1
          end
        end
      end
      count = 0
      for brand in brands
        if brands_update_user_count[count] == true
          brands_user_counter[count] += 1
          brands_update_user_count[count] = false
        end
        count += 1
      end      
    end   

    count = 0
    total_users = 0
    totaL_amount = 0.0
    for brand in brands
      total_users += brands_user_counter[count]
      totaL_amount += brands_total_payments[count]
      puts "Brand: #{brands[count].name} Users: #{brands_user_counter[count]} Total: �#{brands_total_payments[count]} Average per User: #{brands_total_payments[count]/brands_user_counter[count]}"
      count += 1
    end      
    puts "Total users: #{total_users} Total amount: �#{totaL_amount}"
  end

  desc "Open the website"
  task(:open_website => :environment) do
      conf = StreamburstConfig.find(:first)
      conf = StreamburstConfig.new unless conf
      conf.website_open = true
      conf.save
      puts "Opening website was successful"
  end

  desc "Close the website"
  task(:close_website => :environment) do
      conf = StreamburstConfig.find(:first)
      conf = StreamburstConfig.new unless conf
      conf.website_open = false
      conf.save
      puts "Closing website was successful"
  end 

  desc "Backup"
  task(:backup => :environment) do
      filename = "content_store_production_#{Time.new.strftime("%d%m%y_%H%M%S")}.sql"
      system("mysqldump -u root --force --password=oK4jD9a3 content_store_production > /var/content/backups/#{filename}")
      system("gzip /var/content/backups/#{filename}")
      system("scp /var/content/backups/#{filename}.gz robert@video2.streamburst.tv:/var/content/personalized/backups/#{filename}.gz")
      system("rm /var/content/backups/#{filename}.gz")
  end

  desc "Show roles and rights"
  task(:show_roles_and_rights => :environment) do
      for role in Role.find(:all)
        puts "---- #{role.name} ----"
        for right in role.rights
          puts "__________________________"
          puts "Name: #{right.name}"
          puts "Controller: #{right.controller}"
          puts "Action: #{right.action}"
        end
        puts "-------------------------"
      end
  end

  desc "testa"
  task(:testa => :environment) do
    @logger = Logger.new("/home/robert/work/heimdall.log")
    command = "java -jar /home/robert/work/Azureus/Azureus3.0.3.4.jar  --ui=console"
    torrent = "http://torrent.ibiblio.org/torrents/download/69656ddf6cb102f7a332c73f7cae0a767af81437.torrent"
    @state = "starting"
    @start_time = Time.now.to_i
    @set_settings = true
    az = IO.popen(command, "w+")
    loop do
      line = az.readline
      if @set_settings
        az.puts "set \"update.start\" 0\r\n" 
        az.puts "set \"AutoSpeed Max Upload KBs\" 65\r\n"
        az.puts "set \"update.periodic\" 0"
        az.puts "set \"max.uploads.when.busy.inc.min.secs\" 7\r\n"
        az.puts "set \"Max Download Speed KBs\" 450\r\n"
        az.puts "set \"Auto Update\" 0\r\n"
        az.puts "set \"Core_iMaxPeerConnectionsTotal\" 72\r\n"
        az.puts "set \"Max Upload Speed Seeding KBs\" 72\r\n"
        az.puts "set \"Max Upload Speed\" 72\r\n"
        az.puts "set \"Max Uploads Seeding\" 72\r\n"
        az.puts "set \"Pause Downloads On Exit\" 1\r\n"
	@set_settings = false
      end
      @logger.info(line.gsub("\n",''))
    #  @logger.info("in")
#     if @state == "starting" and @start_time < Time.now.to_i - 5
      if @state == "starting" and line =~ /(off console)/i
        @logger.info("Adding torrent")
        az.puts "add #{torrent}\r\n"
        @state = "waiting"
      end
      if @state == "waiting" and (line =~ /(Total Connected Peers)/i or line =~ /(starting torrent)/i)
        az.puts "show t\r\n" 
        sleep(0.5)
      elsif @state == "waiting" and line =~ /(100.0%)/i
        @logger.info("DONE")
	break
      end
      $defout.flush
    end
    raise MediaFormatException if $?.exitstatus != 0
  end

  desc "Show h264 payments"
  task(:show_h264_payments => :environment) do
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
    puts "short downloads totals"
    s_short_download_count_by_month.each do |key, value|
      puts "#{key},#{value},0.0"
    end
    puts "long downloads totals"
    s_long_download_count_by_month.each do |key, value|
      puts "#{key},#{value},#{value*0.02}"
    end
  end

  desc "Show audio watermark payments"
  task(:show_audio_watermark_payments => :environment) do
    aws = MediaWatermark.find_all_by_used(1, :order => "line_item_id")
    last_usd_ex_rate = 0.483053
    last_eur_ex_rate = 0.696397
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
          else
            puts "ERROR NO CURRENCY CODE"
          end
        else
          #puts "warning no currency rate"
          if aw.line_item.currency_code == "USD"
            exchange_rate = last_usd_ex_rate
          elsif aw.line_item.currency_code == "EUR"
            exchange_rate = last_eur_ex_rate
          else
            puts "ERROR NO CURRENCY CODE"
          end
        end
      end
      puts "#{aw.updated_at.strftime("%Y-%m")},#{aw.watermark},#{aw.line_item.order.id},#{aw.line_item.id},#{aw.line_item.currency_code},#{exchange_rate},#{aw.line_item.total_price},#{aw.line_item.total_price*exchange_rate}"
      grand_total += aw.line_item.total_price*exchange_rate
    end
    puts "Grand total #{grand_total}"
  end

  desc "Export help as yaml"
  task(:export_help_as_yaml => :environment) do
    super_hash = Hash.new
    help_hash = super_hash["en"] = Hash.new
    Help.find(:all).each do |help|
      subhash = help_hash["help_id_#{help.id}"] = Hash.new
      subhash["title"]=help.title
      subhash["text"]=help.text
    end
    f=File.open("help.yml",'w')
    YAML::dump(super_hash,f)
  end
end

