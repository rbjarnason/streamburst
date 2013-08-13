class SponsorBrand
  
  attr_reader :advertisement, :price, :sponsor_discount, :sponsor_price, :product_id, :bid_id, :sponsor_bid_amount
  attr_writer :advertisement, :price, :sponsor_discount, :sponsor_price, :product_id, :bid_id, :sponsor_bid_amount

  def initialize(advertisement, price, sponsor_discount, sponsor_price, product_id, bid_id, sponsor_bid_amount)
    self.advertisement = advertisement
    self.price = price
    self.sponsor_discount = sponsor_discount
    self.sponsor_price = sponsor_price
    self.product_id = product_id 
    self.bid_id = bid_id
    self.sponsor_bid_amount = sponsor_bid_amount
  end   
end
  
