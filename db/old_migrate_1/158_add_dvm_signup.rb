class AddDvmSignup < ActiveRecord::Migration
  def self.up
    add_column :users, :fb_user_id, :integer
    execute("alter table users modify fb_user_id bigint")
    add_column :orders, :affiliate_percent, :integer, :default => 0
    add_column :users, :active_facebook_dvm_id, :integer
  end

  def self.down
  end
end
