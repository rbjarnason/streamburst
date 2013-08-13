class CreateBrandCountryBlockers < ActiveRecord::Migration
  def self.up
    create_table :brand_country_blockers do |t|
      t.column :brands_categories_id, :integer
      t.column :country_code, :string
    end
  end

  def self.down
    drop_table :brand_country_blockers
  end
end
