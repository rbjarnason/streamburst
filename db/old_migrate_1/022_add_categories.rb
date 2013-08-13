class AddCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.column "name" , :string, :unique => true
    end
    
    create_table :categories_products, :id => false do |t|
      t.column "category_id" , :integer
      t.column "product_id" , :integer
    end
  end

  def self.down
    drop_table :categories_products
    drop_table :categories
  end
end
