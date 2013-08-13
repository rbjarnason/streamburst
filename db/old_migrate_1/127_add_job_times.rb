class AddJobTimes < ActiveRecord::Migration
  def self.up
    create_table "video_preparation_times", :force => true do |t|
      t.column "video_server_id", :integer
      t.column "time", :float, :default => 0.4
      t.column "activity_type", :integer
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
    end
    
    VideoPreparationJob.delete_all

    add_column :video_preparation_jobs, :video_server_id, :integer
    remove_column :video_preparation_jobs, :video_server_hostname
    add_column :video_preparation_jobs, :estimated_preparation_time, :integer, :default => 0
    add_column :video_preparation_jobs, :status_text, :text
    add_column :video_preparation_jobs, :activity_timing_type, :integer, :default => 1
    remove_column :video_preparation_jobs, :start_processing_time
    remove_column :video_preparation_jobs, :end_processing_time
    add_column :video_preparation_jobs, :start_processing_time, :integer
    add_column :video_preparation_jobs, :end_processing_time, :integer

    add_index :video_preparation_jobs, [:job_key], :unique => true

    # Set small preparation_start_timing value
    preparation_time = VideoPreparationTime.new
    preparation_time.video_server_id = 0
    preparation_time.activity_type = 0
    preparation_time.time = 0.001
    preparation_time.save
  end

  def self.down
  end
end
