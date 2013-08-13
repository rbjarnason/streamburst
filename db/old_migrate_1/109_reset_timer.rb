class ResetTimer < ActiveRecord::Migration
  def self.up
    q = VideoPreparationQueue.find_by_name("main")
    q.last_preparation_wait_time = 120
    q.save
    q = VideoPreparationQueue.find_by_name("wait")
    q.last_preparation_wait_time = 120
    q.save
  end

  def self.down
  end
end
