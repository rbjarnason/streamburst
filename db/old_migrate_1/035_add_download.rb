class AddDownload < ActiveRecord::Migration
  def self.up
    drop_table :mobile_downloads
    create_table :downloads do |t|
      t.column "file_name", :string
      t.column "sha1_hash", :string
      t.column "des_key", :string
      t.column "active", :boolean
    end
    
    add_column :downloads, :created_at, :timestamp
    add_column :downloads, :updated_at, :timestamp
    add_column :formats, :x264options, :string
    add_column :formats, :audio_codec, :string
    add_column :formats, :video_codec, :string
    remove_column :formats, :codec_name
    remove_column :product_formats, :mobile_download_id
    add_column :product_formats, :download_id, :integer    
  end

  def self.down
  end
end
