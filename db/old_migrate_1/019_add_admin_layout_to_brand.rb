class AddAdminLayoutToBrand < ActiveRecord::Migration
  def self.up
    add_column :brands, :admin_layout_name, :string
  end

  def self.down
    remove_column :brands, :admin_layout_name
  end
end
