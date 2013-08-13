class AddPermissionsForWatermarkCacheTargets < ActiveRecord::Migration
  def self.up
    adminrole = Role.find_by_name("Admin")
    
    all_rights = Right.create :name => "Watermark Cache Targets All",
                              :controller => "watermark_cache_targets",
                              :action => "*"
    all_rights.save

    adminrole.rights << all_rights
    adminrole.save    
  end

  def self.down
  end
end
