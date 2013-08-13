class RenameLink < ActiveRecord::Migration
  def self.up
    rename_table :video_preparation_queue_jobs, :video_preparation_jobs_video_preparation_queues
  end

  def self.down
  end
end
