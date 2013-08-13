class AddWatchNow < ActiveRecord::Migration
  def self.up
    add_column :products, :watch_now_filename, :string
  end

  def self.down
  end
end
