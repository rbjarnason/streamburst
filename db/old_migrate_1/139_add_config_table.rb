class AddConfigTable < ActiveRecord::Migration
  def self.up
    create_table :streamburst_config do |t|
      t.column "website_open", :boolean, :default => false
    end
  end

  def self.down
  end
end
