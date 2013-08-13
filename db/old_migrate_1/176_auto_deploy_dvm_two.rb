class AutoDeployDvmTwo < ActiveRecord::Migration
  def self.up
    remove_column :users, :facebook_fb_sig_user
    remove_column :users, :bebo_fb_sig_user
    add_column :users, :facebook_fb_sig_user, :string
    add_column :users, :bebo_fb_sig_user, :string
  end
  
  def self.down
  end
end
