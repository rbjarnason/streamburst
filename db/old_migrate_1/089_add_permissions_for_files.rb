class AddPermissionsForFiles < ActiveRecord::Migration
  def self.up
    adminrole = Role.find_by_name("Admin")
 
    advertisements_files_all_rights = Right.create :name => "Advertisements Files All",
                                     :controller => "advertisements_files",
                                     :action => "*"
    advertisements_files_all_rights.save

    adminrole.rights << advertisements_files_all_rights
    adminrole.save
  end

  def self.down
  end
end
