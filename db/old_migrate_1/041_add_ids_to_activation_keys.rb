class AddIdsToActivationKeys < ActiveRecord::Migration
  def self.up
    add_column :activation_keys, :format_id, :integer
    add_column :activation_keys, :company_id, :integer
    add_column :activation_keys, :brand_id, :integer
    add_column :activation_keys, :order_id, :integer
  end

  def self.down
  end
end
