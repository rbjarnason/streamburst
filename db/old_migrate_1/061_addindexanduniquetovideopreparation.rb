class Addindexanduniquetovideopreparation < ActiveRecord::Migration
  def self.up
    add_index :video_preparation_job_keys, :user_id, :unique => true 
  end

  def self.down
  end
end
