class ChangeFormat < ActiveRecord::Migration
  def self.up
    rename_column :formats, :mp3_audio_only, :audio_only
  end

  def self.down
  end
end
