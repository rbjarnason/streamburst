class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.column :title, :string
      t.column :description, :text
      t.column :image, :string
      t.column :flash_movie, :string
      t.column :divx_movie, :string
      t.column :price, :integer
    end
  end

  def self.down
    drop_table :products
  end
end
