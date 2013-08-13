class ChangeToUnsigned < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE audio_watermarks MODIFY watermark INT UNSIGNED NOT NULL"
    execute "ALTER TABLE video_watermarks MODIFY watermark INT UNSIGNED NOT NULL"
  end

  def self.down
  end
end
