class LatestInitialData < ActiveRecord::Migration
  def self.up
    customer_role = Role.create :name => "Customer"
    customer_role.save

    adminrole = Role.create :name => "Admin"

    torrent_user = TorrentUser.find_by_username("cs_admin")
    
    if torrent_user
      torrent_user.destroy
      torrent_user.save
    end
  
    adminuser = User.create :email => "admin",
            			    :email_confirmation => "admin",
                            :password => "sund44",
                            :password_confirmation => "sund44",
                            :first_name => "admin",
			                :last_name => "admin",
			                :address_1 => "admin home",
            			    :town => "admin town",
                            :postcode => "admin postcode",
			                :country => "admin country"
    
    adminuser.roles << adminrole
 
    if adminuser.save
      puts "save user complete"
    else
      puts "save user FAILED"
    end

    puts adminuser.to_s

    brands_all_rights = Right.create :name => "Brands All",
                                     :controller => "brands",
                                     :action => "*"
    brands_all_rights.save

    companies_all_rights = Right.create :name => "Companies All",
                                        :controller => "companies",
                                        :action => "*"
    companies_all_rights.save

    hosts_all_rights = Right.create :name => "Hosts All",
                                    :controller => "hosts",
                                    :action => "*"
    hosts_all_rights.save

    orders_all_rights = Right.create :name => "Orders All",
                                     :controller => "orders",
                                     :action => "*"
    orders_all_rights.save

    products_all_rights = Right.create :name => "Products All",
                                       :controller => "products",
                                       :action => "*"
    products_all_rights.save
                                     
    rights_all_rights = Right.create :name => "Rights All",
                                     :controller => "rights",
                                     :action => "*"
    rights_all_rights.save

    roles_all_rights = Right.create :name => "Roles All",
                                     :controller => "roles",
                                     :action => "*"
    roles_all_rights.save

    users_all_rights = Right.create :name => "Users All",
                                     :controller => "users",
                                     :action => "*"
    users_all_rights.save

    categories_all_rights = Right.create :name => "Categories All",
                                         :controller => "categories",
                                         :action => "*"
    categories_all_rights.save

    formats_all_rights = Right.create :name => "Formats All",
                                      :controller => "formats",
                                      :action => "*"
    formats_all_rights.save

    downloads_all_rights = Right.create :name => "Downloads All",
                                        :controller => "downloads",
                                        :action => "*"
    downloads_all_rights.save

    torrents_all_rights = Right.create :name => "Torrents All",
                                       :controller => "torrents",
                                       :action => "*"
    torrents_all_rights.save

    price_classes_all_rights = Right.create :name => "PriceClasses All",
                                            :controller => "price_classes",
                                            :action => "*"
    price_classes_all_rights.save
              
    adminrole.rights << brands_all_rights
    adminrole.rights << companies_all_rights
    adminrole.rights << hosts_all_rights
    adminrole.rights << orders_all_rights
    adminrole.rights << products_all_rights
    adminrole.rights << rights_all_rights
    adminrole.rights << roles_all_rights
    adminrole.rights << users_all_rights
    adminrole.rights << categories_all_rights
    adminrole.rights << formats_all_rights
    adminrole.rights << downloads_all_rights
    adminrole.rights << torrents_all_rights
    adminrole.rights << price_classes_all_rights
    adminrole.save
    
    customer_role.save

    streamburst_company = Company.create :name => "Streamburst Ltd"
    streamburst_company.save

    bigearth_company = Company.create :name => "Big Earth Ltd"
    bigearth_company.save

    streamburst_brand = Brand.create :name => "Streamburst",
                                     :layout_name => "streamburst",
                                     :admin_layout_name => "streamburst_admin",
                                     :company_id => streamburst_company.id
    streamburst_brand.save

    lwr_brand = Brand.create :name => "Long Way Round",
                             :layout_name => "long_way_round",
                             :admin_layout_name => "long_way_round_admin",
                             :company_id => bigearth_company.id
    lwr_brand.save
    
    rtd_brand = Brand.create :name => "Race To Daka",
                             :layout_name => "race_to_dakar",
                             :admin_layout_name => "race_to_dakar_admin",
                             :company_id => bigearth_company.id
    rtd_brand.save
    
    localhost = Host.create :name => "localhost"
    streamburst_host = Host.create :name => "www.streamburst.net"
    lwr_host = Host.create :name => "store.longwayround.com"
    rtd_host = Host.create :name => "store.racetodakar.com"
    
    localhost.brands << lwr_brand
    localhost.save

    streamburst_host.brands << streamburst_brand
    streamburst_host.save

    lwr_host.brands << lwr_brand
    lwr_host.save
    
    rtd_host.brands << rtd_brand
    rtd_host.save
  end

  def self.down
  end
end
