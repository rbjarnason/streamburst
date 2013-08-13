class AddAudioVideoWatermarks < ActiveRecord::Migration
  def self.up
    add_column :products, :use_audio_watermarking, :boolean, :default => false
    add_column :products, :use_video_watermarking, :boolean, :default => false
  end

  def self.down
  end
end
