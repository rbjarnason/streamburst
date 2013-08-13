class ChangeToTorrent < ActiveRecord::Migration
  def self.up
    add_column :products, :torrent, :binary
    remove_column :products, :bittorrent_uri
    add_column :users, :torrent_user_id, :integer
    add_column :line_items, :download_key, :string, :limit => 32
    add_column :orders, :user_id, :integer
  end

  def self.down
    add_column :orders, :user_id
    remove_column :line_items, :download_key
    remove_column :users, :torrent_user_id
    add_column :products, :bittorrent_uri
    remove_column :products, :torrent
  end
end
