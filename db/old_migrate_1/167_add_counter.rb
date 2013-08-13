class AddCounter < ActiveRecord::Migration
  def self.up
    add_column :dvm_templates, :get_dvm_click_counter, :integer, :default => 0
  end

  def self.down
  end
end
