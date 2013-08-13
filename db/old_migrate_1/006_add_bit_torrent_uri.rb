class AddBitTorrentUri < ActiveRecord::Migration
  def self.up
    add_column :products, :bittorrent_uri, :string
  end

  def self.down
    remove_column :products, :bittorrent_uri
  end
end
