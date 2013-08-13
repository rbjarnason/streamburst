class AddActivationKeyToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :activation_key, :string    
  end

  def self.down
  end
end
