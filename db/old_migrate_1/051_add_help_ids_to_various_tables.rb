class AddHelpIdsToVariousTables < ActiveRecord::Migration
  def self.up
    add_column :formats, :help_id, :integer
    add_column :categories, :help_id, :integer
    add_column :products, :help_id, :integer
  end

  def self.down
  end
end
