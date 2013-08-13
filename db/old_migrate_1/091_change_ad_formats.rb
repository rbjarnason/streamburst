class ChangeAdFormats < ActiveRecord::Migration
  def self.up
    drop_table :advertisements_formats
    create_table :advertisements_formats do |t|
      t.column :advertisement_id, :integer
      t.column :advertisements_file_id, :integer
      t.column :format_id, :integer
    end

  end

  def self.down
  end
end
