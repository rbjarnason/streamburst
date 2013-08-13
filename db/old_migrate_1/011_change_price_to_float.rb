class ChangePriceToFloat < ActiveRecord::Migration
  def self.up
    change_column :products, :price, :float, :limit => 10, :default => 0.0, :null => false
  end

  def self.down
    change_column :products, :price, :integer
  end
end
