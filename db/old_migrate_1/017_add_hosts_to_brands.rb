class AddHostsToBrands < ActiveRecord::Migration
  def self.up
    remove_column :brands, :host

    create_table :hosts do |t|
      t.column "name" , :string, :unique => true
    end
    
    create_table :brands_hosts, :id => false do |t|
      t.column "brand_id" , :integer
      t.column "host_id" , :integer
    end    
  end

  def self.down
    add_column :brands, :host, :string
    drop_table :brands_hosts
    drop_table :hosts
  end
end
