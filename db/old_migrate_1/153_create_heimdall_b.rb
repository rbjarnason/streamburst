class CreateHeimdallB < ActiveRecord::Migration
  def self.up
    add_column :heimdall_site_targets, :heimdall_content_target_id, :integer
  end

  def self.down
  end
end
