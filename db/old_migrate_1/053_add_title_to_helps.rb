class AddTitleToHelps < ActiveRecord::Migration
  def self.up
    add_column :helps, :title, :string
  end

  def self.down
  end
end
