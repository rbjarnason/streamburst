class AddCardNameToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :card_name, :string
  end

  def self.down
  end
end
