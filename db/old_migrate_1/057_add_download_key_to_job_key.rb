class AddDownloadKeyToJobKey < ActiveRecord::Migration
  def self.up
    add_column :video_preparation_job_keys, :download_key, :string
  end

  def self.down
  end
end
