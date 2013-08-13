class OrderMailer < ActionMailer::Base

  def isotv_free_wozniak(email, discount_code)
    @subject       = "In Search of the Valley FREE Steve Wozniak download"
    @recipients    = email
    @from          = 'steve@ohear.net'
    @body["discount_code"] = discount_code
    @sent_on    = Time.now    
  end

  def isotv_free_film(email, discount_code)
    @subject       = "In Search of the Valley FREE Film download"
    @recipients    = email
    @from          = 'steve@ohear.net'
    @body["discount_code"] = discount_code
    @sent_on    = Time.now    
  end

  def confirm(order)
    @subject       = "Order confirmation from the Content Store"
    @recipients    = order.email
    @from          = 'robert.bjarnason@gmail.com'
    @body["order"] = order
    @sent_on    = Time.now
  end

  def download_ready(order, host, brand, sent_at = Time.now)
    @subject       = "#{brand.name} - #{I18n.translate(:order_confirmation_title)} #{order.id}"
    @recipients    = order.email
    @from          = 'support@streamburst.tv'
    @body["order"] = order
    @body["host"] = host
    @body["brand"] = brand
    @sent_on    = Time.now
  end

  def streamburst_newsletter(user, news_letter_number, sent_at = Time.now)
    @subject       = "Streamburst Newsletter #{news_letter_number}"
    @recipients    = user.email
    @from          = 'newsletter@streamburst.tv'
    @body["user"] = user
    @sent_on    = Time.now    
  end
end
