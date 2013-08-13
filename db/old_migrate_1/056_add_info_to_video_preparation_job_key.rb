class AddInfoToVideoPreparationJobKey < ActiveRecord::Migration
  def self.up
    add_column :video_preparation_job_keys, :user_id, :integer
    add_column :video_preparation_job_keys, :download_id, :integer
    add_column :video_preparation_job_keys, :format_id, :integer
    add_column :video_preparation_job_keys, :product_id, :integer
  end

  def self.down
  end
end
