class ChangeVideoPrepDlKey < ActiveRecord::Migration
  def self.up
    remove_column :video_preparation_job_keys, :download_key
    add_column :video_preparation_job_keys, :downloads_key, :string
  end

  def self.down
  end
end
