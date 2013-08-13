class CartItem

  attr_reader :product, :quantity, :currency_code, :sponsor_bid_id, :sponsor_bid_amount

  def initialize(product, currency_code)
    @product = product
    @quantity = 1
    @currency_code = currency_code
    @sponsor_bid_amount = 0
    @sponsor_bid_id = nil
  end
  
  def increment_quantity
    #Disabled for now
    #@quantity += 1
  end

  def set_bid(bid_id, bid_amount)
    @sponsor_bid_id = bid_id
    @sponsor_bid_amount = bid_amount
  end

  def remove_bid
    @sponsor_bid_amount = 0
    @sponsor_bid_id = nil
  end
  
  def title
    "#{@product.title}"
  end

  def sponsor_discount
    if @sponsor_bid_id != nil
      if @sponsor_bid_amount != nil
        if self.currency_code == "GBP"
          @sponsor_bid_amount * USD_TO_GBP_CONVERSION_RATE
        elsif self.currency_code == "EUR"
          @sponsor_bid_amount * USD_TO_EUR_CONVERSION_RATE
        else
          @sponsor_bid_amount
        end
      else
        0
      end
    else
      0
    end
  end

  def price_with_currency
    if self.currency_code == "GBP" 
      "&pound;#{"%.2f" % self.price}"
    elsif self.currency_code == "EUR" 
      "&euro;#{"%.2f" % self.price}"
    elsif self.currency_code == "ISK" 
      "#{"%.0f" % self.price} kr."
    else 
      "$#{"%.2f" % self.price}"
    end
  end

  def price
    if self.currency_code == "GBP"
      [0, (@product.price_class.price_gbp - sponsor_discount), 0].max
    elsif self.currency_code == "EUR" 
      [0, (@product.price_class.price_eur - sponsor_discount), 0].max
    elsif self.currency_code == "ISK" 
      [0, (@product.price_class.price_isk - sponsor_discount), 0].max
    else 
      [0, (@product.price_class.price_usd - sponsor_discount), 0].max
    end
  end
end
