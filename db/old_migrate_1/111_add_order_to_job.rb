class AddOrderToJob < ActiveRecord::Migration
  def self.up
    add_column :video_preparation_jobs, :order_id, :integer
  end

  def self.down
  end
end
