# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  US_MEDIA_SERVERS = ["video2","video2"]
  US_MEDIA_SERVERS_WEIGHTS = [1,1]
  UK_MEDIA_SERVERS = ["video2","video2"]
  UK_MEDIA_SERVERS_WEIGHTS = [1,1]

  def get_product_format_image(format_type)
    if format_type == 1
      "HD_format_icon.png"
    elsif format_type == 2
      "High Quality_format_icon.png"
    elsif format_type == 3
      "Portable_format_icon.png"
    elsif format_type == 4
      "Mobile_format_icon.png"
    elsif format_type == 5
      "MP3_160_format_icon.png"
    elsif format_type == 6
      "MP3_320_format_icon.png"
    elsif format_type == 7
      "WAV-16-441_format_icon.png"
    elsif format_type == 8
      "WAV_24-48_format_icon.png"
    elsif format_type == 9
      "Cover_Artwork_format_icon.png"
    else
      ""
    end
  end
  
  def create_current_url_with_locale(locale)
    url_for(:controller=>controller_name, :action=>action_name, :params=>params.merge(:locale=>"#{locale}"))
  end
  
  def get_session_id_url_param
    @session_on ? "?_session_id=#{session.session_id}" : ""
  end

  def logged_in?
    text = "<em><small>#{t(:not_logged_in)}</small></em>" 
    if session[:user_id]
      @user = User.find(session[:user_id])
      if @user
        text = "<em><small>#{t(:logged_in_as)} #{@user.email}</small></em>"
      end
    end
    text
   end

  def am_i_admin?
    if session[:user_id]
      @user = User.find(session[:user_id])
      @user.roles.detect{|role| 
                      debug(role.name)
                      role.name == "Admin" }
    end
  end   

  def get_hours(duration)
    hours = duration ? duration / 3600 : 0
  end

  def get_minutes(duration)
    minutes = duration ? duration % 3600 / 60 : 0
  end

  def get_seconds(duration)
    seconds = duration ? duration % 3600 % 60 : 0
  end

  def to_duration_s(duration)
    hours = get_hours(duration)
    minutes = get_minutes(duration)
    seconds = get_seconds(duration)
    duration_s = ""
    if hours > 0
      duration_s << hours.to_s << ":"
    end
    if minutes > 0
      duration_s << minutes.to_s << ":"
    end
    duration_s << seconds.to_s
    duration_s
  end

  def to_duration_long_s(duration)
    hours = get_hours(duration)
    minutes = get_minutes(duration)
    seconds = get_seconds(duration)
    duration_s = ""
    if hours > 0
      duration_s << hours.to_s << " #{t(:hr)} "
    end
    if minutes > 0
      duration_s << minutes.to_s << " #{t(:min)} "
    end
    duration_s << seconds.to_s << " #{t(:sec)}"
    duration_s
  end

  def help(id, options = {})
    if options[:big]
      image_file = "button_help.png"
      image_size = "17x16"
    else
      image_file = "button_help_small.png"
      image_size = "12x12"
    end
    link_to_remote_redbox image_tag((options[:image_file_name] || image_file), 
                                             :id => (options[:image_file_name] == nil ? "help-icon" : "help-icon-format"), 
                                             :border => 0, :alt => t(:Help),
                                             :size=> (options[:image_size] || image_size)), 
                                             :url => {:controller => 'helps', 
                                                      :action => 'get_help', 
                                                      :id => id,
                                                      :substitute => options[:substitute]}
  end
  
  def watch_now_button(filename, title, button_image = "button_watchNow_1.png")
    link_to_remote_redbox image_tag(localized_image_filename(button_image), 
                                             :border => 0, :alt => t(:Watch_Now)),
                                             :url => {:controller => 'catalogue', 
                                                      :action => 'watch_now', 
                                                      :watch_now_filename => filename,
                                                      :title => title}
  end

  def instructions_button
    link_to_remote_redbox image_tag("icon_help_1.png",
                                             :border => 0, :alt => "Instruction", :alt => t(:Instructions), :size => "21x21", :class => "info_help_button", :valign => "middle"),
                                             :url => {:controller => 'catalogue', 
                                                      :action => 'instructions'}
  end
  
  def protected_download_url(download, hostname)
    secret = "Ndj4jBc9sB"
    uri_prefix = "/personalized/"
    filename = "/file/#{session[:user_id]}/#{download.id}/#{download.file_name}"
    t = Time.now.to_i.to_s( base=16 ) # unixtime in hex
    hash = Digest::MD5.new
    hash << "#{secret}#{filename}#{t}"
    "https://#{hostname}#{uri_prefix}#{hash}/#{t}#{filename}"
  end
  
  def getDirectDownloadUrl(product, format_id, file_name)    
    if RAILS_ENV=="production"
      server_prefix = @country_code=="US" ? US_MEDIA_SERVERS.random(US_MEDIA_SERVERS_WEIGHTS) : UK_MEDIA_SERVERS.random(UK_MEDIA_SERVERS_WEIGHTS)
    else
      server_prefix = "video2"
    end
    secret = "Fn23F2t43hb61dADF"
    uri_prefix = "/direct/"
    filename = "/#{product.company_id}/#{product.brand_id}/#{format_id}/#{file_name}"
    t = Time.now.to_i.to_s( base=16 ) # unixtime in hex
    hash = Digest::MD5.new
    hash << "#{secret}#{filename}#{t}"
    "https://#{server_prefix}.streamburst.tv#{uri_prefix}#{hash}/#{t}#{filename}"    
  end
  
  def link_to_remote_fallback(name, options = {}, html_options = {}, *parameters_for_method_reference)
    html_options = html_options.stringify_keys
    html_options["id"] ||= create_ujs_id
    link_to(name, options[:url], html_options, parameters_for_method_reference )<<
    javascript_tag(
                   create_ujs_handler(html_options["id"], 
                                      'click', 
                                      remote_function(options),
                                      {:stop_event => true})
                   )
  end
  
  def create_ujs_handler(id, evt, javascript, options = {})
    options = {:stop_event => false}.merge(options)
    opt = options[:stop_event] ? 'Event.stop(e);' : ''
    "Event.observe('#{id}', '#{evt}', function(e){#{opt}#{javascript}});"
  end
  
  def create_ujs_id
     "ujs_#{rand.to_s.match(/(\d\d+)/).captures.first}"
  end
  
  def value_to_currency(total) 
    if @currency_code == "GBP" 
      number_to_currency(total, :unit => "&pound;") 
    elsif @currency_code == "EUR" 
      number_to_currency(total, :unit => "&euro;") 
    elsif @currency_code == "ISK" 
      number_to_currency(total, :unit => "kr.", :precision=>0, :format => "%n %u") 
    else 
      number_to_currency(total, :unit => "$", :format => "%u%n") 
    end 
  end  
  
  def get_short_date(date_obj)
    if date_obj
      "#{"%02d/%02d/%04d" % [date_obj.day, date_obj.month, date_obj.year]}"
    else
      "nil"
    end
  end    
  
  def google_analytics_e_commerce(order)
    if order and RAILS_ENV == "production"
      unless order.sent_to_analytics == true || order.total_price_gbp == 0
        order.sent_to_analytics = true
        order.save
        beginning = "<form style=\"display:none;\" name=\"utmform\">\
          <textarea id=\"utmtrans\">UTM:T|#{order.id}|#{@brand.name}|#{order.total_price_gbp}|0|0|na|na|#{@country_code} "
        line_items = ""
        for line_item in order.line_items
          line_items += "UTM:I|#{order.id}|#{line_item.product.id}|#{line_item.product.title}|#{line_item.product.categories[0].name}|#{line_item.price_gbp}|1 "
        end
        logger.info("cs_info: Sent order #{order.id} to Google analytics")
        beginning + line_items + "</textarea> </form>" + "<script type=\"text/javascript\">\
                                                              __utmSetTrans();\
                                                           </script>"
      else
        logger.info("cs_info: Order #{order.id} NOT sent to Google analytics sent: #{order.sent_to_analytics} total_price: #{order.total_price_gbp}")
      end
    else
      logger.error("cs_error: Nil order for google_analytics_e_commerce") if RAILS_ENV == "production"
    end
  end

  def image_localized_submit_tag(source, options = {})
    image_submit_tag(localized_image_filename(source), options)
  end

  def image_localized_tag(source, options = {})
    image_tag(localized_image_filename(source), options)
  end

  def localized_image_filename(source)
    prepend = ""
    if @brand.custom_products_list
      prepend = "#{@brand.to_home_param}/"
    end
    if I18n.locale.to_s != "en"
      s = source.split(".")
      source = "#{s[0]}_#{I18n.locale.to_s}.#{s[1]}"
    end
    prepend+source
  end
  
  def localized_image_filename_with_currency(source)
    prepend = ""
    if @brand.custom_products_list
      prepend = "#{@brand.to_home_param}/"
    end
    s = source.split(".")
    source = "#{s[0]}_#{I18n.locale.to_s}_#{@currency_code.downcase}.#{s[1]}"
    prepend+source
  end
end
