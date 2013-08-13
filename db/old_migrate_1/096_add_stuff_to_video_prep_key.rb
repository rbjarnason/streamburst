class AddStuffToVideoPrepKey < ActiveRecord::Migration
  def self.up
    rename_table :video_preparation_job_keys, :video_preparation_jobs
    add_column :video_preparation_jobs, :preperation_args, :text
    add_column :video_preparation_jobs, :active, :boolean
    add_column :video_preparation_jobs, :in_progress, :boolean, :default => false
    add_column :video_preparation_jobs, :cancelled, :boolean, :default => false
    add_column :video_preparation_jobs, :timed_out, :boolean, :default => false
    add_column :video_preparation_jobs, :email_when_finished, :boolean, :default => false
    add_column :video_preparation_jobs, :error, :string
    add_column :video_preparation_jobs, :audio_watermark, :integer, :null => false, :unique => true
    add_column :video_preparation_jobs, :video_watermark, :integer, :null => false, :unique => true
  end

  def self.down
  end
end
