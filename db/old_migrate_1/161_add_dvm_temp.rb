class AddDvmTemp < ActiveRecord::Migration
  def self.up
    add_column :dvm_templates, :preview_dvm_id, :integer
  end

  def self.down
  end
end
