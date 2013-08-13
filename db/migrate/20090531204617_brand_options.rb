class BrandOptions < ActiveRecord::Migration
  def self.up
    add_column :brands, :checkout_confirm_on_top, :boolean, :default=>false
  end

  def self.down
  end
end
