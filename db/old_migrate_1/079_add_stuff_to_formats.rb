class AddStuffToFormats < ActiveRecord::Migration
  def self.up
    add_column :formats, :text_truncate_len, :integer
    add_column :formats, :text_background_enabled, :boolean, :default => false
    
    hq_format = Format.find(1)
    hq_format.text_truncate_len = 60
    hq_format.save

    portable_format = Format.find(4)
    portable_format.text_truncate_len = 42
    portable_format.save   
    
    mobile_format = Format.find(5)
    mobile_format.text_truncate_len = 39
    mobile_format.save

  end

  def self.down
  end
end
