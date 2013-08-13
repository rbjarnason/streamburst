class ChangeAdminFlag < ActiveRecord::Migration
  def self.up
    change_column :users, :admin_flag, :boolean
  end

  def self.down
    change_column :users, :admin_flag, :integer
  end
end
