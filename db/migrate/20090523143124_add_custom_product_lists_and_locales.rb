class AddCustomProductListsAndLocales < ActiveRecord::Migration
  def self.up
    add_column :brands, :custom_products_list, :boolean, :default=>false
    add_column :brands, :filter_by_locale, :boolean, :default=>false
    add_column :products, :locale_filter, :string
  end

  def self.down
  end
end
