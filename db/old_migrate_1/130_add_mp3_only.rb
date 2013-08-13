class AddMp3Only < ActiveRecord::Migration
  def self.up
    add_column :formats, :mp3_audio_only, :boolean, :default => false
  end

  def self.down
  end
end
