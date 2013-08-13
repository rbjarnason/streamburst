class AddActivationKey < ActiveRecord::Migration
  def self.up
    create_table :activation_keys, :id => false do |t|
      t.column :activation_key, :string
      t.column :user_id, :integer
      t.column :file_name, :string
      t.column :sha1_hash, :string
      t.column :des_key, :string
      t.column :version, :integer
      t.column :active, :boolean
    end
    
    add_index :activation_keys, :activation_key
    add_column :activation_keys, :created_at, :timestamp
    add_column :activation_keys, :updated_at, :timestamp
  end

  def self.down
  end
end
