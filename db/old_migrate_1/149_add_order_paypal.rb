class AddOrderPaypal < ActiveRecord::Migration
  def self.up
    add_column :orders, :payflow_message, :string
    add_column :orders, :payflow_result, :integer
    add_column :orders, :payflow_partner, :string
    add_column :orders, :payflow_correlation_id, :string
    add_column :orders, :payflow_pp_ref, :string
    add_column :orders, :payflow_fee_amount, :float
    add_column :orders, :payflow_pn_ref, :string
    add_column :orders, :payflow_vendor, :string
    add_column :orders, :payflow_auth_code, :string
    add_column :orders, :payflow_cv_result, :string
    add_column :orders, :payflow_test, :boolean
    add_column :orders, :payflow_authorization, :string
    add_column :orders, :payflow_success, :boolean
    add_column :orders, :payflow_fraud_review, :string
  end

  def self.down
  end
end
