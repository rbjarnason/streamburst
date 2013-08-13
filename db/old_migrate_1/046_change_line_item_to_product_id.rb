class ChangeLineItemToProductId < ActiveRecord::Migration
  def self.up
    remove_column :line_items, :torrent_id
    remove_column :line_items, :download_id
  end

  def self.down
  end
end
