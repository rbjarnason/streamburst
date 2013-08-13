class AddRightsForSponsorBids < ActiveRecord::Migration
  def self.up
    adminrole = Role.find_by_name("Admin")
 
    campaigns_all_rights = Right.create :name => "Campaigns All",
                                     :controller => "campaigns",
                                     :action => "*"
    campaigns_all_rights.save

    territories_all_rights = Right.create :name => "Territories All",
                                          :controller => "territories",
                                          :action => "*"
    territories_all_rights.save

    advertisement_all_rights = Right.create :name => "Advertisement All",
                                            :controller => "advertisements",
                                            :action => "*"
    advertisement_all_rights.save
    
    bids_all_rights = Right.create :name => "Bids All",
                                   :controller => "bids",
                                   :action => "*"
    bids_all_rights.save

    adminrole.rights << campaigns_all_rights
    adminrole.rights << territories_all_rights
    adminrole.rights << advertisement_all_rights
    adminrole.rights << bids_all_rights
    adminrole.save
  end

  def self.down
  end
end
