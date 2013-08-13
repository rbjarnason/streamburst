class AddLocaleToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :locale, :string
  end

  def self.down
  end
end
