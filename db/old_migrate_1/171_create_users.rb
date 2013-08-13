class CreateUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :bebo_id, :string
  end
  
  def self.down
  end
end
