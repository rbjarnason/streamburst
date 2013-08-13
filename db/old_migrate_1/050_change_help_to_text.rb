class ChangeHelpToText < ActiveRecord::Migration
  def self.up
    remove_column :helps, :text
    add_column :helps, :text, :text
  end

  def self.down
  end
end
