class AddToDvmB < ActiveRecord::Migration
  def self.up
    rename_table :dvm_template, :dvm_templates
    add_column :dvms, :dvm_template_id, :integer

    create_table "brands_dvm_templates", :id => false, :force => true do |t|
      t.column "brand_id", :integer
      t.column "dvm_template_id", :integer
    end
    
    adminrole = Role.find_by_name("Admin")
    
    rights1 = Right.create :name => "DVM Templates",
                           :controller => "dvm_templates",
                           :action => "*"
    rights1.save

    adminrole.rights << rights1
    adminrole.save    

    customerrole = Role.find_by_name("Customer")
    
    rights1 = Right.create :name => "DVM Signup",
                           :controller => "dvm",
                           :action => "signup"
    rights1.save

#    customerrole.rights << rights1
#    customerrole.save    
    
    dvm_affiliate = Role.create :name => "DVM Affiliate"
    dvm_affiliate.save

    rights1 = Right.create :name => "DVM All",
                           :controller => "dvm",
                           :action => "*"
    rights1.save

    dvm_affiliate.rights << rights1
  end

  def self.down
  end
end
