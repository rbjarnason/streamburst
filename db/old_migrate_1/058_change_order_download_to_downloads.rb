class ChangeOrderDownloadToDownloads < ActiveRecord::Migration
  def self.up
    remove_column :orders, :download_key
    add_column :orders, :downloads_key, :string
  end

  def self.down
  end
end
