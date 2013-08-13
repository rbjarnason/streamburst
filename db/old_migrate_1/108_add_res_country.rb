class AddResCountry < ActiveRecord::Migration
  def self.up
   add_column :video_preparation_jobs, :residence_country, :string
  end

  def self.down
  end
end
