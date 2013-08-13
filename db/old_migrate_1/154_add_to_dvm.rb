class AddToDvm < ActiveRecord::Migration
  def self.up
    create_table :dvm_template do |t|
      t.column "title", :string
      t.column "swf_url", :string
      t.column "image", :string
      t.column "small_title", :string
      t.column "weight", :integer
      t.column "active", :boolean
      t.column "global_brand_access", :boolean
      t.column "created_at", :timestamp
      t.column "updated_at", :timestamp
    end
    
    add_column :users, :paypal_email, :string
    add_column :users, :dvm_affiliate, :boolean, :default => false
  end

  def self.down
  end
end
