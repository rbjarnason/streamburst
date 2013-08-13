class AddAudioVideoWatermarkMore < ActiveRecord::Migration
  def self.up
    add_column :orders, :has_mp3_watermark, :boolean, :default => false
    add_column :orders, :has_mp4_watermark, :boolean, :default => false
    remove_column :orders, :has_audio_watermark
    remove_column :orders, :has_video_watermark
    add_column :products, :mp3_audio_only, :boolean, :default => false
  end

  def self.down
  end
end
