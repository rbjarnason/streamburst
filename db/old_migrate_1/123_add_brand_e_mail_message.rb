class AddBrandEMailMessage < ActiveRecord::Migration
  def self.up
    add_column :brands, :email_marketing_message, :text
  end

  def self.down
  end
end
