class AddFormatType < ActiveRecord::Migration
  def self.up
    add_column :formats, :type, :integer
  end

  def self.down
  end
end
