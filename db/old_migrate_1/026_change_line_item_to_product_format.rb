class ChangeLineItemToProductFormat < ActiveRecord::Migration
  def self.up
    remove_column :line_items, :product_id
    add_column :line_items, :product_format_id, :integer
  end

  def self.down
    add_column :line_items, :product_id, :integer
  end
end
