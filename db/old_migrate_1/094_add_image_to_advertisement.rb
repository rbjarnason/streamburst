class AddImageToAdvertisement < ActiveRecord::Migration
  def self.up
    add_column :advertisements, :image, :string
  end

  def self.down
  end
end
