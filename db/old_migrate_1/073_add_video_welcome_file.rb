class AddVideoWelcomeFile < ActiveRecord::Migration
  def self.up
    add_column :brands, :video_welcome_file, :string
  end

  def self.down
  end
end
