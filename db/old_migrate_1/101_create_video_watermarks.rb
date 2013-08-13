class CreateVideoWatermarks < ActiveRecord::Migration
  def self.up
    create_table :video_watermarks do |t|
      t.column :product_id, :integer, :null => false
      t.column :download_id, :integer, :null => false
      t.column :used, :boolean, :default => false
      t.column :reserved, :boolean, :default => false
      t.column :user_id, :integer
      t.column :line_item_id, :integer
      t.column :watermark, :integer, :unique => true, :null => false
      t.column :cache_server_prefix, :string
    end
  end

  def self.down
    drop_table :video_watermarks
  end
end
