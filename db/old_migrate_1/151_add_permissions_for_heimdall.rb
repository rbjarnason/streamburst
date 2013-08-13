class AddPermissionsForHeimdall < ActiveRecord::Migration
  def self.up
    adminrole = Role.find_by_name("Admin")
    
    rights1 = Right.create :name => "Heimdall Site Target",
                           :controller => "heimdall_site_targets",
                           :action => "*"
    rights1.save

    rights2 = Right.create :name => "Heimdall Content Target",
                           :controller => "heimdall_content_targets",
                           :action => "*"
    rights2.save

    adminrole.rights << rights1
    adminrole.rights << rights2
    adminrole.save    
  end

  def self.down
  end
end
