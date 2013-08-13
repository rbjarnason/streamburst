class DirectDownload < ActiveRecord::Migration
  def self.up
    add_column :products, :direct_download, :boolean, :default => false
  end
  
  def self.down
  end
end
