class AddDefaultVals < ActiveRecord::Migration
  def self.up
    q = VideoPreparationQueue.find_by_name("main")
    q.last_preparation_wait_time_per_mb = 0.2
    q.save
    w = VideoPreparationQueue.find_by_name("wait")
    w.last_preparation_wait_time_per_mb = 0.12
    w.save
  end

  def self.down
  end
end
