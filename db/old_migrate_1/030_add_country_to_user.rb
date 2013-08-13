class AddCountryToUser < ActiveRecord::Migration
  def self.up
    add_column :products, :country, :string
  end

  def self.down
    remove_column :products, :country
  end
end
