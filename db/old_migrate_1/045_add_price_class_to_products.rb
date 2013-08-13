class AddPriceClassToProducts < ActiveRecord::Migration
  def self.up
    remove_column :product_formats, :price_class_id
    add_column :products, :price_class_id, :integer
  end

  def self.down
  end
end
