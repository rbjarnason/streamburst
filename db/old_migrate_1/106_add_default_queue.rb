class AddDefaultQueue < ActiveRecord::Migration
  def self.up
    unless VideoPreparationQueue.find_by_name("main")
      queue = VideoPreparationQueue.new
      queue.name = "main"
      queue.save
    end

    wait_queue = VideoPreparationQueue.new
    wait_queue.name = "wait"
    wait_queue.save
  end

  def self.down
  end
end
