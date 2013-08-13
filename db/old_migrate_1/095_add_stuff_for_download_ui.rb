class AddStuffForDownloadUi < ActiveRecord::Migration
  def self.up
    add_column :products, :source_format, :string
    add_column :products, :master_filename, :string
    
    add_column :formats, :pass_1_video_codec_options, :string
    add_column :formats, :pass_2_video_codec_options, :string
    add_column :formats, :audio_codec_options, :string
    add_column :formats, :audio_channels, :integer
    add_column :formats, :audio_delay, :float
    add_column :formats, :avs_field_deinterlace, :string
    add_column :formats, :avs_lancoz_resize, :string
  end

  def self.down
  end
end
