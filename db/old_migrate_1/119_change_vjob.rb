class ChangeVjob < ActiveRecord::Migration
  def self.up
    change_column :video_preparation_jobs, :added_to_queue_time, :integer
  end

  def self.down
  end
end
