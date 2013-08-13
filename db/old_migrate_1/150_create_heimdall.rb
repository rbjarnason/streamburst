class CreateHeimdall < ActiveRecord::Migration
  def self.up
    create_table :heimdall_site_targets do |t|
      t.column "title", :string
      t.column "url", :string
      t.column "type", :string # rss or single_torrent
      t.column "processing_time_interval", :integer
      t.column "last_processing_time", :timestamp
      t.column "active", :boolean
      t.column "created_at", :timestamp
      t.column "updated_at", :timestamp
    end

    add_index :heimdall_site_targets, [:url], :unique => true

    create_table :heimdall_content_targets do |t|
      t.column "search_titles", :string # Comma seperated titles
      t.column "brand_id", :integer
      t.column "active", :boolean
      t.column "created_at", :timestamp
      t.column "updated_at", :timestamp
    end

    create_table :heimdall_possible_matches do |t|
      t.column "heimdall_content_target_id", :integer
      t.column "heimdall_site_target_id", :integer
      t.column "first_detected_at", :timestamp
      t.column "last_detected_at", :timestamp
      t.column "download_started_at", :timestamp
      t.column "detection_count", :integer
      t.column "download_completed_at", :timestamp
      t.column "published_date", :timestamp
      t.column "processing_stage", :string
      t.column "title", :string
      t.column "url", :string
      t.column "indicated_file_size", :integer
      t.column "num_pieces", :integer
      t.column "real_file_size", :integer
      t.column "multiple_files", :boolean
      t.column "sha1", :string
      t.column "md5sum", :string
      t.column "description", :string
      t.column "category", :string
      t.column "torrent_file", :binary
      t.column "active", :boolean
      t.column "created_at", :timestamp
      t.column "updated_at", :timestamp
    end
  end

  def self.down
  end
end
