class AddRangeNameToVouchers < ActiveRecord::Migration
  def self.up
    add_column :discount_vouchers, :range_name, :string
  end

  def self.down
  end
end
