class CreateWatermarkCacheTargets < ActiveRecord::Migration
  def self.up
    create_table :watermark_cache_targets do |t|
      t.column :download_id, :integer
      t.column :weight, :integer
      t.column :audio_watermark_gain, :integer, :default => 0
    end
  end

  def self.down
    drop_table :watermark_cache_targets
  end
end
