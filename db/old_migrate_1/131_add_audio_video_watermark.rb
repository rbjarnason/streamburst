class AddAudioVideoWatermark < ActiveRecord::Migration
  def self.up
    add_column :orders, :has_audio_watermark, :boolean, :default => false
    add_column :orders, :has_video_watermark, :boolean, :default => false
  end

  def self.down
  end
end
