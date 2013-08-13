class VideoPreparationMailer < ActionMailer::Base

  def preparation_complete(order, host, brand_name, product_title, job_key, sent_at = Time.now)
    order.localize_on_complete
    @subject       = "#{brand_name} - \"#{product_title}\" #{I18n.translate :is_ready_for_download}"
    @recipients    = order.email
    @from          = 'support@streamburst.tv'
    @body["order"] = order
    @body["host"] = host
    @body["brand_name"] = brand_name
    @body["product_title"] = product_title
    @body["job_key"] = job_key
    @sent_on    = Time.now
  end
end
