class AddCompleteFlagToVideoPrep < ActiveRecord::Migration
  def self.up
    add_column :video_preparation_job_keys, :complete, :boolean, :default => false, :null => false
  end

  def self.down
  end
end
