class AddPaypalInfoToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :country_code, :string
    add_column :orders, :total_price, :float
    add_column :orders, :paypal_first_name, :string
    add_column :orders, :paypal_last_name, :string
    add_column :orders, :paypal_residence_country, :string
    add_column :orders, :paypal_receiver_id, :string
    add_column :orders, :paypal_payer_id, :string
    add_column :orders, :paypal_payer_email, :string
    add_column :orders, :paypal_verify_sign, :string
    add_column :orders, :paypal_mc_currency, :string
    add_column :orders, :paypal_payer_status, :string
    add_column :orders, :paypal_payment_status, :string
    add_column :orders, :paypal_payment_date, :string
    add_column :orders, :paypal_payment_type, :string
    add_column :orders, :paypal_num_cart_items, :integer
    add_column :orders, :paypal_mc_gross, :float
  end

  def self.down
  end
end
