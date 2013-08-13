class AddToJob < ActiveRecord::Migration
  def self.up
    add_column :video_preparation_jobs, :no_work_done, :boolean, :default => false
  end

  def self.down
  end
end
