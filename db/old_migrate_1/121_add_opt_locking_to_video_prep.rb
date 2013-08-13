class AddOptLockingToVideoPrep < ActiveRecord::Migration
  def self.up
    add_column :video_preparation_jobs, :lock_version, :integer, :default => 0
  end

  def self.down
  end
end
