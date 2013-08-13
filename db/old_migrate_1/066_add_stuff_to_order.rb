class AddStuffToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :status, :string
    add_column :orders, :cancelled_by_user, :boolean
  end

  def self.down
  end
end
