class AddAwGain < ActiveRecord::Migration
  def self.up
    add_column :products, :audio_watermark_gain, :integer, :default => 0
  end

  def self.down
  end
end
