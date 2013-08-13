class AddGoogleOrderId < ActiveRecord::Migration
  def self.up
    add_column :orders, :google_order_number, :string
    add_index :orders, [:google_order_number], :unique => true
  end
  
  def self.down
  end
end
