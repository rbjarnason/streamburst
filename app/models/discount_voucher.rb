class DiscountVoucher < ActiveRecord::Base
 def discount
   if self.currency_code == "GBP" 
     self.discount_gbp 
   elsif self.currency_code == "EUR" 
     self.discount_eur
   elsif self.currency_code == "ISK"
     self.discount_isk
   else 
     self.discount_usd 
  end
 end
end
