class AddToDvmD < ActiveRecord::Migration
  def self.up
    add_column :dvm_templates, :height, :integer
    add_column :dvm_templates, :width, :integer
  end

  def self.down
  end
end
