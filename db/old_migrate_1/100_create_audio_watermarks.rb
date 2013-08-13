class CreateAudioWatermarks < ActiveRecord::Migration
  def self.up
    create_table :audio_watermarks do |t|
      t.column :product_id, :integer, :null => false
      t.column :download_id, :integer, :null => false
      t.column :used, :boolean, :default => false
      t.column :reserved, :boolean, :default => false
      t.column :user_id, :integer
      t.column :line_item_id, :integer
      t.column :watermark, :integer, :unique => true, :null => false
      t.column :cache_server_prefix, :string
    end

    remove_column :video_preparation_jobs, :audio_watermark
    remove_column :video_preparation_jobs, :video_watermark
  end

  def self.down
    drop_table :audio_watermarks
  end
end
