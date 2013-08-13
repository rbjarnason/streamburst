class ChangeActivationKey < ActiveRecord::Migration
  def self.up
    remove_column :orders, :activation_key
  end

  def self.down
  end
end
