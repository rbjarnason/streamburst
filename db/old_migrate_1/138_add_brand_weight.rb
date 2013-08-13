class AddBrandWeight < ActiveRecord::Migration
  def self.up
    add_column :brands, :weight, :integer, :default => 0
    add_column :brands, :help_id, :integer, :default => 0
  end

  def self.down
  end
end
