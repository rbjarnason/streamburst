class AddStoreHost < ActiveRecord::Migration
  def self.up
    add_column :video_preparation_jobs, :content_store_host, :string
  end

  def self.down
  end
end
