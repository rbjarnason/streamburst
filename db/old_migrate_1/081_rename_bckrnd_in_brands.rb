class RenameBckrndInBrands < ActiveRecord::Migration
  def self.up
    rename_column :brands, :page_backround_color, :page_background_color
  end

  def self.down
  end
end
