class CreateVideoPreparationQueues < ActiveRecord::Migration
  def self.up
    create_table :video_preparation_queues do |t|
      t.column :name, :string
      t.column :active, :boolean
      t.column :last_preparation_wait_time, :integer
    end

    create_table "video_preparation_queue_jobs", :id => false, :force => true do |t|
      t.column "video_preparation_queue_id", :integer
      t.column "video_preparation_job_id", :integer
    end
  end

  def self.down
    drop_table :video_preparation_queues
  end
end
