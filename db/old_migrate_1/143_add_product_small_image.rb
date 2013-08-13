class AddProductSmallImage < ActiveRecord::Migration
  def self.up
    add_column :products, :small_image, :string
  end

  def self.down
  end
end
