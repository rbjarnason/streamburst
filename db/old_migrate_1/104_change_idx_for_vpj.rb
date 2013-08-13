class ChangeIdxForVpj < ActiveRecord::Migration
  def self.up
    remove_index :video_preparation_jobs, :name => "video_preparation_job_keys_user_id_index"
    add_index :video_preparation_jobs, :user_id
  end

  def self.down
  end
end
