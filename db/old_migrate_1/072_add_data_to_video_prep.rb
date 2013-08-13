class AddDataToVideoPrep < ActiveRecord::Migration
  def self.up
    add_column :video_preparation_job_keys, :success, :boolean, :default => false, :null => false
    add_column :video_preparation_job_keys, :progress, :integer, :default => 0, :null => false
    add_column :video_preparation_job_keys, :middleman_uri, :string, :null => false
    add_column :video_preparation_job_keys, :content_server_prefix, :string, :null => false
    add_column :video_preparation_job_keys, :completed_at, :timestamp
  end

  def self.down
  end
end
