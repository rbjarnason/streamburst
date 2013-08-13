class AddIsk < ActiveRecord::Migration
  def self.up
    add_column :price_classes, :price_isk, :float, :default=>2000.0
    add_column :discount_vouchers, :discount_isk, :float
    
    customerrole = Role.find_by_name("Customer")
    
    right1 = Right.create :name => "ISK Payment",
                           :controller => "checkout",
                           :action => "isk_payment"
    right1.save

    customerrole.rights << right1
  end

  def self.down
  end
end
