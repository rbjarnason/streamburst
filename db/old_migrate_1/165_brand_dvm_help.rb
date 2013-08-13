class BrandDvmHelp  < ActiveRecord::Migration
  def self.up
    add_column :brands, :dvm_main_help, :text
  end

  def self.down
  end
end
