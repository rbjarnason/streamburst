class CreateHelps < ActiveRecord::Migration
  def self.up
    create_table :helps do |t|
      t.column :text, :string
    end
  end

  def self.down
    drop_table :helps
  end
end
