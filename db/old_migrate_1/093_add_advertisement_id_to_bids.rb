class AddAdvertisementIdToBids < ActiveRecord::Migration
  def self.up
    add_column :bids, :advertisement_id, :integer
  end

  def self.down
  end
end
