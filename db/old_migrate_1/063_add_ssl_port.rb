class AddSslPort < ActiveRecord::Migration
  def self.up
    add_column :hosts, :ssl_port, :integer
  end

  def self.down
  end
end
