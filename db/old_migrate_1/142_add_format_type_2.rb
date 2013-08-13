class AddFormatType2 < ActiveRecord::Migration
  def self.up
    rename_column :formats, :type, :format_type
  end

  def self.down
  end
end
