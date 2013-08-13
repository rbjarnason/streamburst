class AddJoinTable < ActiveRecord::Migration
  def self.up
    create_table :advertisements_advertisements_formats, :id => false do |t|
      t.column :advertisement_id, :integer
      t.column :advertisments_format_id, :integer
    end

  end

  def self.down
  end
end
