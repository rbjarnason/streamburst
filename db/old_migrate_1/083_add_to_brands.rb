class AddToBrands < ActiveRecord::Migration
  def self.up
    add_column :brands, :image, :string
    add_column :brands, :logo, :string
    add_column :brands, :flash_trailer, :string
    add_column :brands, :flash_trailer_small, :string
    add_column :brands, :description, :text
  end

  def self.down
  end
end
