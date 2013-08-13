class FixAds < ActiveRecord::Migration
  def self.up
    remove_column :advertisements_advertisements_formats, :advertisments_format_id
    add_column :advertisements_advertisements_formats, :advertisements_format_id, :integer
  end

  def self.down
  end
end
