class LineItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :user
  belongs_to :product
  belongs_to :discount_voucher

  def self.from_cart_item(cart_item)
    li = self.new
    li.product_id = cart_item.product.id
    li.quantity    = cart_item.quantity
    li.total_price = cart_item.price
    li.currency_code = cart_item.currency_code
    li
  end

  def price=(price)
    if price
      self.total_price = price
    end
  end

  def price_with_currency
    value_to_currency(price)
  end
 
  def discount_with_currency
    value_to_currency([get_voucher_discount,self.total_price].min)
  end
    
  def price
    price = total_price
    price -= get_voucher_discount if self.discount_voucher
    [price, 0].max
  end

  def price_real_gbp
    Product.find(self.product_id).price_class.price_gbp
  end

  def price_gbp
    return price unless self.currency_code
    case self.currency_code
    when "GBP"
      price
    when "EUR"
      price * GBP_TO_EUR_CONVERSION_RATE
    when "USD"
      price * GBP_TO_USD_CONVERSION_RATE
    when "ISK"
      price * GBP_TO_ISK_CONVERSION_RATE
    end
  end

private

  def value_to_currency(value)
    if self.currency_code == nil || self.currency_code == "GBP"
      "&pound;"+sprintf("%.2f",value)
    elsif self.currency_code == "EUR" 
      "&euro;"+sprintf("%.2f",value)
    elsif self.currency_code == "ISK" 
      "#{sprintf("%.0f",value)} kr."
    else 
      "$"+sprintf("%.2f",value)
    end
  end

  def get_voucher_discount
    if self.currency_code == nil || self.currency_code == "GBP" 
      self.discount_voucher.discount_gbp 
    elsif self.currency_code == "EUR" 
      self.discount_voucher.discount_eur
    elsif self.currency_code == "ISK" 
      self.discount_voucher.discount_isk
    else 
      self.discount_voucher.discount_usd
    end
  end
end
