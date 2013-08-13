class AddGlobalBrandAccessFlag < ActiveRecord::Migration
  def self.up
    add_column :brands, :global_brand_access, :boolean
  end

  def self.down
    remove_column :brands, :global_brand_access
  end
end
