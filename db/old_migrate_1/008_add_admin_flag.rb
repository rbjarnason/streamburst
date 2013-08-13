class AddAdminFlag < ActiveRecord::Migration
  def self.up
    add_column :users, :admin_flag, :integer, :limit => 1
  end

  def self.down
    remove_column :users, :admin_flag
  end
end
