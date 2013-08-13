class AddToJobTwo < ActiveRecord::Migration
  def self.up
    add_column :video_preparation_jobs, :file_size_mb, :integer
  end

  def self.down
  end
end
