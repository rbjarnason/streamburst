class AddCurrencyCodeLineItem < ActiveRecord::Migration
  def self.up
    add_column :line_items, :currency_code, :string
  end

  def self.down
  end
end
