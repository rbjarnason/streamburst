class AddDiscountVoucherIdToLineItem < ActiveRecord::Migration
  def self.up
    add_column :line_items, :discount_voucher_id, :integer
  end

  def self.down
  end
end
