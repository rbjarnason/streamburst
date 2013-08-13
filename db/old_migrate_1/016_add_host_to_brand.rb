class AddHostToBrand < ActiveRecord::Migration
  def self.up
    add_column :brands, :host, :string
  end

  def self.down
    remove_column :brands, :host  
  end
end
