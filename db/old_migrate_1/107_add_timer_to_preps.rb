class AddTimerToPreps < ActiveRecord::Migration
  def self.up
    add_column :video_preparation_jobs, :added_to_queue_time, :datetime
    add_column :video_preparation_jobs, :start_processing_time, :datetime
    add_column :video_preparation_jobs, :end_processing_time, :datetime
  end

  def self.down
  end
end
