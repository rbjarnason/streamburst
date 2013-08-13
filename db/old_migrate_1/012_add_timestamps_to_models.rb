class AddTimestampsToModels < ActiveRecord::Migration
  def self.up
    add_column :products, :created_at, :timestamp
    add_column :products, :updated_at, :timestamp
    add_column :users, :created_at, :timestamp
    add_column :users, :updated_at, :timestamp
    add_column :orders, :created_at, :timestamp
    add_column :orders, :updated_at, :timestamp
  end

  def self.down
    remove_column :products, :created_at
    remove_column :products, :updated_at
    remove_column :users, :created_at
    remove_column :users, :updated_at
    remove_column :orders, :created_at
    remove_column :orders, :updated_at
  end
end
