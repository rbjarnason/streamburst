class DvnClickImage  < ActiveRecord::Migration
  def self.up
    add_column :dvm_templates, :large_click_image, :string
  end

  def self.down
  end
end
