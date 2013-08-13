class MyspaceHack < ActiveRecord::Migration
  def self.up
    add_column :dvms, :myspace_hack, :boolean, :default => false
  end
  
  def self.down
  end
end
