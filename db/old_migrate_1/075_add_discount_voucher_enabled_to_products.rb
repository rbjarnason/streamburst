class AddDiscountVoucherEnabledToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :discount_voucher_enabled, :boolean, :default => false

    adminrole = Role.find_by_name("Admin")
    discount_vouchers_rights = Right.create :name => "Discount Vouchers Admin",
                                            :controller => "discount_vouchers",
                                            :action => "*"
    discount_vouchers_rights.save
                   
    adminrole.rights << discount_vouchers_rights
    adminrole.save
  end

  def self.down
  end
end
