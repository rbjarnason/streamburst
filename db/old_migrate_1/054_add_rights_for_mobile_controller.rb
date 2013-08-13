class AddRightsForMobileController < ActiveRecord::Migration
  def self.up
    adminrole = Role.find_by_name("Admin")
    customerrole = Role.find_by_name("Customer")
 
    mobile_all_rights = Right.create :name => "Mobile All",
                                        :controller => "mobile",
                                        :action => "*"
    mobile_all_rights.save
    
    adminrole.rights << mobile_all_rights
    adminrole.save
    
    customerrole.rights << mobile_all_rights
    customerrole.save
  end

  def self.down
  end
end
