class CreateVideoPreparationJobKeys < ActiveRecord::Migration
  def self.up
    create_table :video_preparation_job_keys do |t|
      t.column :job_key, :string
      t.column :created_at, :timestamp
      t.column :updated_at, :timestamp
    end
  end

  def self.down
    drop_table :video_preperation_job_keys
  end
end
