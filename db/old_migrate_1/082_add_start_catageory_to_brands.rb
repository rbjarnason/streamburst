class AddStartCatageoryToBrands < ActiveRecord::Migration
  def self.up
   add_column :brands, :start_category_id, :integer
  end

  def self.down
  end
end
