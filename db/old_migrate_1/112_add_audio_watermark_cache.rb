class AddAudioWatermarkCache < ActiveRecord::Migration
  def self.up
    add_column :audio_watermarks, :cache_video_server_id, :integer, :default => 0
    add_column :audio_watermarks, :created_at, :datetime
    add_column :audio_watermarks, :updated_at, :datetime
    remove_column :audio_watermarks, :cache_server_prefix
  end

  def self.down
  end
end
