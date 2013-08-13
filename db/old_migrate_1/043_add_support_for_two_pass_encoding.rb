class AddSupportForTwoPassEncoding < ActiveRecord::Migration
  def self.up
    remove_column :formats, :x264options
    add_column :formats, :pass_1_codec_options, :string
    add_column :formats, :pass_2_codec_options, :string
  end

  def self.down
  end
end
