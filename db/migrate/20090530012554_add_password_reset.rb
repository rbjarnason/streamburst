class AddPasswordReset < ActiveRecord::Migration
  def self.up
    add_column :users, :reset_password_code, :string
    add_column :users, :reset_password_code_until, :datetime
    add_index "users", ["reset_password_code"], :name => "users_reset_password_code_index", :unique => true

    customerrole = Role.find_by_name("Customer")
    
    right1 = Right.create :name => "Login forgot_password",
                           :controller => "users",
                           :action => "forgot_password"
    right1.save

    right2 = Right.create :name => "Login reset password",
                           :controller => "users",
                           :action => "reset"
    right2.save

    customerrole.rights << right1
    customerrole.rights << right2
  end

  def self.down
  end
end
