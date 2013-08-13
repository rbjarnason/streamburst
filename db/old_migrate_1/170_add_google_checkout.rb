class AddGoogleCheckout < ActiveRecord::Migration
  def self.up
    add_column :orders, :google_checkout_key, :string
    add_index :orders, [:google_checkout_key], :unique => true
  end

  def self.down
  end
end
