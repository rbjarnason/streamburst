class AddRightsForHelps < ActiveRecord::Migration
  def self.up
    adminrole = Role.find_by_name("Admin")
    customerrole = Role.find_by_name("Customer")
 
    helps_all_rights = Right.create :name => "Helps All",
                                        :controller => "helps",
                                        :action => "*"
    helps_all_rights.save

    helps_get_help_rights = Right.create :name => "Helps All",
                                        :controller => "helps",
                                        :action => "get_help"
    helps_get_help_rights.save
    
    adminrole.rights << helps_all_rights
    adminrole.save
    
    customerrole.rights << helps_get_help_rights
    customerrole.save
  end

  def self.down
  end
end
