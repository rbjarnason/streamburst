class AddParentProduct < ActiveRecord::Migration
  def self.up
    create_table :child_products, :id => false do |t|
      t.column "product_id" , :integer, :null => false
      t.column "child_product_id" , :integer, :null => false
    end
    add_column :products, :parent_flag, :boolean, :default => false
    add_column :dvm_templates, :parent_product_id, :integer
  end

  def self.down
  end
end
