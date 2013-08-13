class AddToWatermarks < ActiveRecord::Migration
  def self.up
    add_column :watermark_cache_targets, :audio_watermark_enabled, :boolean, :default => false
    add_column :watermark_cache_targets, :video_watermark_enabled, :boolean, :default => false
    add_column :watermark_cache_targets, :audio_codec, :string
  end

  def self.down
  end
end
