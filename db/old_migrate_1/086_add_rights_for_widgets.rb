class AddRightsForWidgets < ActiveRecord::Migration
  def self.up
    adminrole = Role.find_by_name("Admin")
 
    widget_all_rights = Right.create :name => "Widgets All",
                                        :controller => "widgets",
                                        :action => "*"
    widget_all_rights.save

    adminrole.rights << widget_all_rights
    adminrole.save    
  end

  def self.down
  end
end
