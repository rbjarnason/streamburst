class AddCompleteToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :complete, :boolean
  end

  def self.down
  end
end
