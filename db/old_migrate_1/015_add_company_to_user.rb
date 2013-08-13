class AddCompanyToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :company_id, :integer
  end

  def self.down
    remove_column :user, :company_id
  end
end
