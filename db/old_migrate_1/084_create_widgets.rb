class CreateWidgets < ActiveRecord::Migration
  def self.up
    create_table :widgets do |t|
      t.column :name, :string
      t.column :company_id, :integer
      t.column :token, :string
    end
  end

  def self.down
    drop_table :widgets
  end
end
