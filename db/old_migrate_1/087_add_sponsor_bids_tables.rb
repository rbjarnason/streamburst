class AddSponsorBidsTables < ActiveRecord::Migration
  def self.up
    create_table :campaigns do |t|
      t.column :name, :string
      t.column :company_id, :integer
      t.column :territory_id, :integer
      t.column :advertisement_id, :integer
      t.column :start_date, :timestamp
      t.column :end_date, :timestamp
      t.column :active, :boolean
      t.column :max_daily_bid_amount, :float
      t.column :today_total_bid_won_amount, :float
      t.column :total_bid_won_amount, :float
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end

    create_table :advertisements do |t|
      t.column :name, :string
      t.column :company_id, :integer
      t.column :total_exposures, :integer
      t.column :duration, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end

    create_table :advertisements_formats, :id => false do |t|
      t.column :advertisement_id, :integer
      t.column :advertisements_file_id, :integer
      t.column :format_id, :integer
    end

    create_table :advertisements_files do |t|
      t.column :file_name, :string
      t.column :sha1_hash, :string
      t.column :des_key, :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end

    create_table :bids do |t|
      t.column :campaign_id, :integer
      t.column :territory_id, :integer
      t.column :bid_amount, :float
      t.column :active, :boolean
      t.column :today_won_amount, :float
      t.column :total_won_amount, :float
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end

    create_table :won_bids do |t|
      t.column :bid_id, :integer
      t.column :line_item_id, :integer
      t.column :bid_amount, :float
      t.column :completed, :boolean
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end

    create_table :tags do |t|
      t.column :name, :string
    end

    create_table :bids_tags, :id => false do |t|
      t.column :bid_id, :integer
      t.column :tag_id, :integer
    end

    create_table :products_tags, :id => false do |t|
      t.column :product_id, :integer
      t.column :tag_id, :integer
    end
            
    add_column :line_items, :won_bid_id, :integer
        
    create_table :territories do |t|
      t.column :name, :string
      t.column :country_codes, :string
    end
  end

  def self.down
  end
end
