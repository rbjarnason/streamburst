class CreateHeimdallA < ActiveRecord::Migration
  def self.up
    rename_column :heimdall_site_targets, :type, :url_type
  end

  def self.down
  end
end
