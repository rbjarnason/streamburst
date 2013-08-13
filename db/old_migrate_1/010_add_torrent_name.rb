class AddTorrentName < ActiveRecord::Migration
  def self.up
    add_column :products, :torrent_name, :string
  end

  def self.down
    remove_column :products, :torrent_name
  end
end
