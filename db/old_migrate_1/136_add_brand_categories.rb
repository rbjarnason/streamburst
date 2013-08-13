class AddBrandCategories < ActiveRecord::Migration
  def self.up
    create_table :brand_categories do |t|
      t.column "name" , :string, :unique => true
    end
    
    create_table :brand_categories_brands, :id => false do |t|
      t.column "brand_category_id" , :integer
      t.column "brand_id" , :integer
    end
  end

  def self.down
  end
end
