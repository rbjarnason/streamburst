class AddEmailHave < ActiveRecord::Migration
  def self.up
    add_column :video_preparation_jobs, :sent_email, :boolean, :default => false
  end

  def self.down
  end
end
