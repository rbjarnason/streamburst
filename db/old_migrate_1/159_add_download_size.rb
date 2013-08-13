class AddDownloadSize < ActiveRecord::Migration
  def self.up
    add_column :downloads, :file_size_mb, :integer
  end

  def self.down
  end
end
