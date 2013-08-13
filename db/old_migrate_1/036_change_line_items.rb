class ChangeLineItems < ActiveRecord::Migration
  def self.up
    remove_column :line_items, :mobile_download_id
    add_column :line_items, :download_id, :integer
  end

  def self.down
  end
end
