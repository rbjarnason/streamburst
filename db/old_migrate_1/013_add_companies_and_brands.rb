class AddCompaniesAndBrands < ActiveRecord::Migration
  def self.up
    create_table :companies do |t|
      t.column :name, :string
    end

    create_table :brands do |t|
      t.column :name, :string
      t.column :company_id, :integer
      t.column :layout_name, :string
    end
    
    add_column :products, :company_id, :integer
    add_column :products, :brand_id, :integer
    add_index :products, :brand_id
  end

  def self.down
    drop_table :brands
    drop_table :companies
    remove_index :products, :brand_id
    remove_column :products, :brand_id
    remove_column :products, :company_id
  end
end
