class CreateBrandsWidgets < ActiveRecord::Migration
  def self.up
    create_table :brands_widgets, :id => false, :force => true do |t|
      t.column :brand_id, :integer
      t.column :widget_id, :integer
    end
  end

  def self.down
    drop_table :brands_widgets
  end
end
