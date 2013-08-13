class PaymentRights < ActiveRecord::Migration
  def self.up
    customerrole = Role.find_by_name("Customer")
    
    right1 = Right.create :name => "Checkout Payment",
                           :controller => "checkout",
                           :action => "payment"
    right1.save

    customerrole.rights << right1
  end

  def self.down
  end
end
