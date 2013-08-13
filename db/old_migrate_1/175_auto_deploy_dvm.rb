class AutoDeployDvm < ActiveRecord::Migration
  def self.up
    add_column :users, :facebook_fb_sig_user, :integer
    add_column :users, :bebo_fb_sig_user, :integer
    add_column :users, :facebook_auto_deployed, :boolean, :default => false
    add_column :users, :bebo_auto_deployed, :boolean, :default => false
  end
  
  def self.down
  end
end
