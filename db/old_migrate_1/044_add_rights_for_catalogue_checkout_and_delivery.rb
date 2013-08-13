class AddRightsForCatalogueCheckoutAndDelivery < ActiveRecord::Migration
  def self.up
    adminrole = Role.find_by_name("Admin")
    customerrole = Role.find_by_name("Customer")
 
    catalogue_all_rights = Right.create :name => "Catalogue All",
                                        :controller => "catalogue",
                                        :action => "*"
    catalogue_all_rights.save

    checkout_all_rights = Right.create :name => "Checkout All",
                                       :controller => "checkout",
                                       :action => "*"
    checkout_all_rights.save

    delivery_all_rights = Right.create :name => "Delivery All",
                                       :controller => "delivery",
                                       :action => "*"
    delivery_all_rights.save
    
    adminrole.rights << catalogue_all_rights
    adminrole.rights << checkout_all_rights
    adminrole.rights << delivery_all_rights
    adminrole.save
    
    customerrole.rights << catalogue_all_rights
    customerrole.rights << checkout_all_rights
    customerrole.rights << delivery_all_rights    
    customerrole.save
  end

  def self.down
  end
end
