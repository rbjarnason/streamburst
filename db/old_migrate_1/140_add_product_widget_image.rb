class AddProductWidgetImage < ActiveRecord::Migration
  def self.up
    add_column :products, :dvm_image, :string
  end

  def self.down
  end
end
