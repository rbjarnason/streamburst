class AddHomeEnabled < ActiveRecord::Migration
  def self.up
    add_column :brands, :home_enabled, :boolean, :default=>false
    b = Brand.find(1)
    b.home_enabled = true
    b.save
  end

  def self.down
  end
end
