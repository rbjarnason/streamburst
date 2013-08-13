class ChangeVidJob < ActiveRecord::Migration
  def self.up
    remove_column :video_preparation_queues, :last_preparation_wait_time
    add_column :video_preparation_queues, :last_preparation_wait_time_per_mb, :float, :default => 0.4
  end

  def self.down
  end
end
