class Dvm < ActiveRecord::Base
  has_and_belongs_to_many :brands
  before_create :generate_token
  belongs_to :dvm_template
  belongs_to :user

  def generate_token
    md5 = Digest::MD5::new
    now = Time::now
    md5.update(now.to_s)
    md5.update(String(now.usec))
    md5.update(String(rand(0)))
    md5.update(String($$))
    md5.update("ro2bor")
    self.token = md5.hexdigest
  end

  def order_count
    return Order.count(:conditions=>"dvm_id = #{self.id}") 
  end

  def value_order_count
    return Order.count(:conditions=>"dvm_id = #{self.id} and total_price > 0")
  end

  def get_order_info
    orders = Order.find_all_by_dvm_id(self.id, :conditions => "paypal_payment_status = 'Completed'")
    gbp_total = 0.0
    usd_total = 0.0
    eur_total = 0.0
    gbp_affiliate_fee_total = 0.0
    usd_affiliate_fee_total = 0.0
    eur_affiliate_fee_total = 0.0
    if orders
      for order in orders
        if order.currency_code == "GBP"
          gbp_total += order.total_price
          gbp_affiliate_fee_total += (order.total_price * (order.affiliate_percent.to_f/100))
        elsif order.currency_code == "USD"
          usd_total += order.total_price
          usd_affiliate_fee_total += (order.total_price * (order.affiliate_percent.to_f/100))
        elsif order.currency_code == "EUR"
          eur_total += order.total_price
          eur_affiliate_fee_total += (order.total_price * (order.affiliate_percent.to_f/100))
        end
      end
      [orders.length, gbp_total, usd_total, eur_total, gbp_affiliate_fee_total, usd_affiliate_fee_total, eur_affiliate_fee_total]
    else
      [0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    end
  end

  def get_js_embed_code
    url = "#{self.dvm_template.swf_url}?token=#{self.token}"
      "<script type=\"text/javascript\" src=\"http://streamburst.tv/javascripts/ufo.js\"></script>\
<script type=\"text/javascript\">\
var FO = { movie:\"#{url}\", width:\"#{self.dvm_template.width}\",\
height:\"#{self.dvm_template.height}\", majorversion:\"8\", build:\"0\",\
wmode:\"transparent\"};\
UFO.create(FO, \"dvm\");\
</script>\
<div id=\"dvm\">\
REPLACE - Replacement content displayed if Flash not avilable - REPLACE\
</div>"
  end

  def get_js_ssl_embed_code
    url = "#{self.dvm_template.swf_url}?token=#{self.token}"
      "<script type=\"text/javascript\" src=\"https://streamburst.tv/javascripts/ufo.js\"></script>\
<script type=\"text/javascript\">\
var FO = { movie:\"#{url}\", width:\"#{self.dvm_template.width}\",\
height:\"#{self.dvm_template.height}\", majorversion:\"8\", build:\"0\",\
wmode:\"transparent\"};\
UFO.create(FO, \"dvm\");\
</script>\
<div id=\"dvm\">\
REPLACE - Replacement content displayed if Flash not avilable - REPLACE\
</div>"
  end

  def get_embed_code
    url = "#{self.dvm_template.swf_url}?token=#{self.token}"
    url = "http"+url.from(5) if url.starts_with?("https")
       "<object width=#{self.dvm_template.width} height=#{self.dvm_template.height}><param name=\"movie\" \
value=\"#{url}\"></param><param name=\"wmode\" value=\"transparent\"></param><embed src=\"#{url}\"\
type=\"application/x-shockwave-flash\" wmode=\"transparent\" width=\"#{self.dvm_template.width}\"\
height=\"#{self.dvm_template.height}\"></embed></object>"
  end
end
