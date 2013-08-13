class AddOrderPaypal < ActiveRecord::Migration
  def self.up
    add_column :orders, :cache_type, :string
    add_column :orders, :paypal_txn_type, :string
    add_column :orders, :paypal_txn_id, :string
    
    add_column :orders, :paypal_address_status, :string
    add_column :orders, :paypal_address_name, :string
    add_column :orders, :paypal_address_street, :string
    add_column :orders, :paypal_address_city, :string
    add_column :orders, :paypal_address_zip, :string
    add_column :orders, :paypal_address_state, :string
    add_column :orders, :paypal_address_country_code, :string
    add_column :orders, :paypal_address_country, :string
    
    add_column :orders, :paypal_receipt_id, :string
    add_column :orders, :paypal_invoice, :integer
    add_column :orders, :paypal_payment_gross, :float
    add_column :orders, :paypal_payment_fee, :float
    add_column :orders, :paypal_settle_currency, :string
    add_column :orders, :paypal_exchange_rate, :float
    add_column :orders, :paypal_settle_amount, :float
    add_column :orders, :paypal_tax, :float
    add_column :orders, :paypal_mc_shipping, :float
    add_column :orders, :paypal_mc_fee, :float
    add_column :orders, :paypal_mc_handling, :float
    
    add_column :orders, :paypal_business, :string
    add_column :orders, :paypal_receiver_email, :string
    add_column :orders, :paypal_notify_version, :string
  end

  def self.down
  end
end
