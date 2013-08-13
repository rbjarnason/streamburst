class MoveCountryFromProductsToUsers < ActiveRecord::Migration
  def self.up
    remove_column :products, :country
    add_column :users, :country, :string
  end

  def self.down
    remove_column :users, :country
    add_column :products, :country, :string
  end
end