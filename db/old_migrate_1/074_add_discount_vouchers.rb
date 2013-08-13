class AddDiscountVouchers < ActiveRecord::Migration
  def self.up
    create_table :discount_vouchers do |t|
      t.column "product_id", :integer
      t.column "order_id", :integer
      t.column "user_id", :integer
      t.column "token", :string
      t.column "discount_gbp", :float
      t.column "discount_usd", :float
      t.column "discount_eur", :float
      t.column "used", :boolean, :default => false
      t.column "created_at", :timestamp
      t.column "updated_at", :timestamp
    end
  end

  def self.down
  end
end
