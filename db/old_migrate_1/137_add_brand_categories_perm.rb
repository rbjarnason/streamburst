class AddBrandCategoriesPerm < ActiveRecord::Migration
  def self.up
    adminrole = Role.find_by_name("Admin")
    
    all_rights = Right.create :name => "Brand Categories All",
                              :controller => "brand_categories",
                              :action => "*"
    all_rights.save

    adminrole.rights << all_rights
    adminrole.save  
  end

  def self.down
  end
end
