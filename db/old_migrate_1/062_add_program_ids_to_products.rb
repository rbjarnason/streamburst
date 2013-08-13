class AddProgramIdsToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :program_id, :integer
  end

  def self.down
  end
end
