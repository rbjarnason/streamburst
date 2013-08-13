class CreateBrandsCategories < ActiveRecord::Migration
  def self.up
    create_table :brands_categories do |t|
      t.column :brand_id, :integer
      t.column :category_id, :integer
    end
  end

  def self.down
    drop_table :brands_categories
  end
end
