class ChangeUsernameAndAddDetail < ActiveRecord::Migration
  def self.up
    remove_column :users, :username
    add_column :users, :title, :string
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :email, :string
    add_column :users, :address_1, :string
    add_column :users, :address_2, :string
    add_column :users, :town, :string
    add_column :users, :county, :string
    add_column :users, :postcode, :string
  end

  def self.down
    add_column :users, :username, :string
    remove_column :users, :title
    remove_column :users, :first_name
    remove_column :users, :last_name
    remove_column :users, :email
    remove_column :users, :address_1
    remove_column :users, :address_2
    remove_column :users, :town
    remove_column :users, :county
    remove_column :users, :postcode
  end
end
