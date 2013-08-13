class MoveDownloadKeyToOrders < ActiveRecord::Migration
  def self.up
    remove_column :line_items, :download_key
    add_column :orders, :download_key, :string, :limit => 32
  end

  def self.down
    remove_column :orders, :download_key
    add_column :line_items, :download_key, :string, :limit => 32
  end
end
