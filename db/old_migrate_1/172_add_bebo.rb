class AddBebo < ActiveRecord::Migration
  def self.up
    add_column :users, :active_bebo_dvm_id, :integer
  end
  
  def self.down
  end
end
