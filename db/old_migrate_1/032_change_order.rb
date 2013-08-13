class ChangeOrder < ActiveRecord::Migration
  def self.up
    remove_column :orders, :name
    remove_column :orders, :address
    remove_column :orders, :pay_type
    add_column :orders, :title, :string
    add_column :orders, :first_name, :string
    add_column :orders, :last_name, :string
    add_column :orders, :address_1, :string
    add_column :orders, :address_2, :string
    add_column :orders, :town, :string
    add_column :orders, :county, :string
    add_column :orders, :postcode, :string
  end

  def self.down
    add_column :orders, :name, :string
    add_column :orders, :address, :string
    add_column :orders, :pay_type, :string
    remove_column :orders, :title
    remove_column :orders, :first_name
    remove_column :orders, :last_name
    remove_column :orders, :address_1
    remove_column :orders, :address_2
    remove_column :orders, :town
    remove_column :orders, :county
    remove_column :orders, :postcode    
  end
end
