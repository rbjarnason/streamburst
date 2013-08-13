class FixTypo < ActiveRecord::Migration
  def self.up
    rename_column :video_preparation_jobs, :preperation_args, :preparation_args
  end

  def self.down
  end
end
