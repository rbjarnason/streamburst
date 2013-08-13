class AddToDvmC < ActiveRecord::Migration
  def self.up
    add_column :orders, :currency_code, :string
#    all_orders = Order.find_all
#    for order in all_orders
#      order.currency_code = order.paypal_mc_currency
#      order.save
#    end
    
    add_column :users, :dvm_id, :integer
    add_column :dvm_templates, :description, :text

    add_column :heimdall_possible_matches, :forensics_start_at, :timestamp
    add_column :heimdall_possible_matches, :forensics_end_at, :timestamp
  end

  def self.down
  end
end
