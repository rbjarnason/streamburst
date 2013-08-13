class AddSentToAnalyticsToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :sent_to_analytics, :boolean
  end

  def self.down
  end
end
