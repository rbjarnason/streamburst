class ChangeWidgetToDvm < ActiveRecord::Migration
  def self.up
    rename_table :widgets, :dvms
    rename_table :brands_widgets, :brands_dvms
    rename_column :brands_dvms, :widget_id, :dvm_id
    add_column :dvms, :created_at, :timestamp
    add_column :dvms, :updated_at, :timestamp
    add_column :dvms, :user_id, :integer
    add_column :dvms, :exposure_count, :integer
    add_column :dvms, :active, :boolean
    add_column :orders, :dvm_id, :integer
    
    create_table "dvms_hosts", :id => false, :force => true do |t|
      t.column "dvm_id", :integer
      t.column "host_id", :integer
      t.column "active", :boolean, :default => false
    end
    
    r = Right.find_by_name("Widgets All")
    r.controller = "dvm"
    r.name = "DVM All"
    r.action = "*"
    r.save
  end

  def self.down
  end
end
