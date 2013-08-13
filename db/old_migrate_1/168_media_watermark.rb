class MediaWatermark < ActiveRecord::Migration
  def self.up
    rename_table :audio_watermarks, :media_watermarks
    add_column :media_watermarks, :has_video_watermark, :boolean, :default => false
  end

  def self.down
  end
end
