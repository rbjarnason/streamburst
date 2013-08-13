class CopyVideoConfigInFormats < ActiveRecord::Migration
  def self.up
    all_formats = Format.find_all
    for format in all_formats
      format.pass_1_video_codec_options = format.pass_1_codec_options.gsub('--output /dev/null', '').gsub('--output','')
      format.pass_2_video_codec_options = format.pass_2_codec_options.gsub('--output /dev/null', '').gsub('--output','')
      format.save
    end

  end

  def self.down
  end
end
