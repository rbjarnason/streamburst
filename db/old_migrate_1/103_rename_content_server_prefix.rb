class RenameContentServerPrefix < ActiveRecord::Migration
  def self.up
    rename_column :video_preparation_jobs, :content_server_prefix, :video_server_hostname
  end

  def self.down
  end
end
