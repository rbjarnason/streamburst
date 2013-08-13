class RenameDvmTemp  < ActiveRecord::Migration
  def self.up
    rename_column :dvm_templates, :small_title, :small_image
  end

  def self.down
  end
end