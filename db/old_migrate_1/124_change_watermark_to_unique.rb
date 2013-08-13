class ChangeWatermarkToUnique < ActiveRecord::Migration
  def self.up
    add_index :audio_watermarks, [:watermark], :unique => true
    add_index :video_watermarks, [:watermark], :unique => true
  end

  def self.down
  end
end
