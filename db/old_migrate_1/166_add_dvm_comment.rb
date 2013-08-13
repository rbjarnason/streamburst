class AddDvmComment < ActiveRecord::Migration
  def self.up
    add_column :dvms, :comment, :string, :default => ""
  end

  def self.down
  end
end
