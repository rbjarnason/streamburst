class AddAudioWatermarkChange < ActiveRecord::Migration
  def self.up
    rename_column :orders, :has_mp3_audio, :has_audio
    rename_column :orders, :has_mp4_video, :has_video
    rename_column :products, :mp3_audio_only, :audio_only    
  end

  def self.down
  end
end
