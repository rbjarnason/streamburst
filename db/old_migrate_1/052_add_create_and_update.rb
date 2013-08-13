class AddCreateAndUpdate < ActiveRecord::Migration
  def self.up
    add_column :line_items, :created_at, :timestamp
    add_column :line_items, :updated_at, :timestamp
  end

  def self.down
  end
end
