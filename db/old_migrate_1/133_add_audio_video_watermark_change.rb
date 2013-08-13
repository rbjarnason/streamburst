class AddAudioVideoWatermarkChange < ActiveRecord::Migration
  def self.up
    remove_column :orders, :has_mp3_watermark
    remove_column :orders, :has_mp4_watermark
    add_column :orders, :has_mp3_audio, :boolean, :default => false
    add_column :orders, :has_mp4_video, :boolean, :default => true
  end

  def self.down
  end
end
