class AddPreviewDvm < ActiveRecord::Migration
  def self.up
    add_column :products, :flv_preview_url, :string, :default => ""
    add_column :products, :flv_preview_image, :string, :default => ""
    add_column :dvm_templates, :affiliate_percent, :integer, :default => 5
    add_column :dvm_templates, :public_access, :boolean, :default => true
  end

  def self.down
  end
end
