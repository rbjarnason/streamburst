class AddIndexToHosts < ActiveRecord::Migration
  def self.up
    add_index :hosts, :name
  end

  def self.down
    remove_index :hosts, :name
  end
end
