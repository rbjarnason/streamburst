class AddCacheTarget < ActiveRecord::Migration
  def self.up
    add_column :watermark_cache_targets, :cache_type, :string, :default => ""
    add_column :audio_watermarks, :cache_type, :string, :default => ""
  end

  def self.down
  end
end
