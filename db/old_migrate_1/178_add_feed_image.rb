class AddFeedImage < ActiveRecord::Migration
  def self.up
    add_column :dvm_templates, :feed_image, :string
  end

  def self.down
  end
end
