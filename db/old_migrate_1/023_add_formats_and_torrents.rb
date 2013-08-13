class AddFormatsAndTorrents < ActiveRecord::Migration
  def self.up
    create_table :formats do |t|
      t.column "name" , :string
      t.column "standard" , :string
      t.column "px_width", :integer
      t.column "px_height", :integer
      t.column "codec_name", :string
    end

    create_table :price_classes do |t|
      t.column "name" , :string
      t.column "price_eur", :float, :limit => 10, :default => 0.0, :null => false
      t.column "price_gbp", :float, :limit => 10, :default => 0.0, :null => false
      t.column "price_usd", :float, :limit => 10, :default => 0.0, :null => false
    end

    create_table :product_formats do |t|
      t.column "format_id", :integer
      t.column "price_class_id", :integer
      t.column "torrent_id", :integer
      t.column "mobile_download_id", :integer
    end

    create_table :product_formats_products, :id => false do |t|
      t.column "product_format_id" , :integer
      t.column "product_id" , :integer
    end

    remove_column :products, :torrent
    remove_column :products, :torrent_name

    create_table :torrents do |t|
      t.column "torrent_data", :binary
      t.column "file_name", :string
      t.column "length", :time
      t.column "des_key", :string
      t.column "active", :boolean
    end

    create_table :mobile_downloads do |t|
      t.column "file_data", :binary
      t.column "file_name", :string
      t.column "sha1_hash", :string
      t.column "des_key", :string
      t.column "active", :boolean
    end

    add_column :line_items, :torrent_id, :integer
    add_column :line_items, :mobile_download_id, :integer

    add_column :products, :active, :boolean
    add_column :products, :duration, :integer
    add_column :products, :rating, :integer

    remove_column :products, :price
    add_column :users, :active, :boolean
    
    add_column :torrents, :created_at, :timestamp
    add_column :torrents, :updated_at, :timestamp
    add_column :mobile_downloads, :created_at, :timestamp
    add_column :mobile_downloads, :updated_at, :timestamp
    add_column :price_classes, :created_at, :timestamp
    add_column :price_classes, :updated_at, :timestamp
    add_column :formats, :created_at, :timestamp
    add_column :formats, :updated_at, :timestamp
    add_column :product_formats, :created_at, :timestamp
    add_column :product_formats, :updated_at, :timestamp
  end

  def self.down
    remove_column :line_items, :torrent_id
    remove_column :line_items, :mobile_download_id
    remove_column :products, :active
    remove_column :users, :active

    drop_table :mobile_downloads
    drop_table :torrents

    add_column :products, :torrent_name, :string
    add_column :products, :torrent, :binary

    remove_index :product_formats, :product_id

    drop_table :product_formats_products
    drop_table :product_formats
    drop_table :price_classes
    drop_table :formats
  end
end
