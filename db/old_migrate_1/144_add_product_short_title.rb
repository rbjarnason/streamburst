class AddProductShortTitle < ActiveRecord::Migration
  def self.up
    add_column :products, :short_title, :string
  end

  def self.down
  end
end
