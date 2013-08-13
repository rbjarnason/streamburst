class AddMaxPerCacheServer < ActiveRecord::Migration
  def self.up
    add_column :watermark_cache_targets, :max_per_cache_server, :integer, :default => 0
  end

  def self.down
  end
end
