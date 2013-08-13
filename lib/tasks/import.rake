require 'pathname'

#video:
#  h264_track_id: 2

class MediaFormatException < StandardError
end

class Shell
  def log_time
    t = Time.now
    "%02d:%02d:%02d.%06d" % [t.hour, t.min, t.sec, t.usec]
  end

  def execute(command)
    puts "Execute: #{command}"
    IO.popen(command) do |pipe|
      pipe.each("\r") do |line|
        puts line
        $defout.flush
      end
    end
    raise MediaFormatException if $?.exitstatus != 0
  end
end

def lookup_names(program_id)
  name_file = File.open("/home/robert/lazytown_2_imports/names.csv","r")
  FasterCSV.parse(name_file.read) do |row|
    if row[0].to_i==program_id
      return {:program_id=>row[0].to_i, :running_order=>row[1].to_i, :name_en=>row[2].strip,
              :name_is=>row[3].strip, :name_sp=>row[4].strip, :name_fr=>row[5].strip,
              :base_filename=>"LazyTown-S2-#{row[1]}-#{row[2].gsub(" ","-")}" }
      break
    end
  end  
end

TEST_WATERMARK = false

namespace :import do
  desc "Fix Spanish"
  task(:fix_spanish_mcf => :environment) do
    @shell = Shell.new
    Dir["/var/content/imports/Streamburst/audio/*.mcf"].each do |file|
      pathname = Pathname.new(file)
      dir = pathname.dirname.to_s
      basename = pathname.basename.to_s
      next unless basename.include?("-sp")
      basename = basename[0..basename.length-7]
      system "mv #{file} #{dir}/#{basename}es.mcf"
    end
  end

  desc "convert to 16bit"
  task(:convert_to_16bit => :environment) do
    @shell = Shell.new
    Dir["/var/content/imports/Streamburst/audio/*.wav"].each do |file|
      pathname = Pathname.new(file)
      dir = pathname.dirname.to_s
      basename = pathname.basename.to_s
      basename = basename[0..basename.length-5]
      @shell.execute("ffmpeg -i #{file} -acodec pcm_s16le #{dir}/#{basename}.16.wav")
      @shell.execute("mv #{file} #{dir}/#{basename}.wold")
      @shell.execute("mv #{dir}/#{basename}.16.wav #{file}")
    end
  end
  
  desc "audio watermark all"
  task(:audio_watermark_all => :environment) do
    @shell = Shell.new
    Dir["/var/content/imports/Streamburst/audio/*.wav"].each do |file|
      next if file.include?("pcm") or file.include?("test_watermark")
      pathname = Pathname.new(file)
      dir = pathname.dirname.to_s
      basename = pathname.basename.to_s
      basename = basename[0..basename.length-5]
      unless FileTest.exist?("#{dir}/#{basename}.pcm-1.tmp.wav")
        @shell.execute("pcm-watermark embed -i #{file} -o #{dir}/#{basename}.pcm-0.tmp.wav -s #{Rails.root}/lib/audio_watermark/setup_0.txt -PCMC0 -KFILE #{Rails.root}/lib/audio_watermark/key.txt")
        @shell.execute("pcm-watermark embed -i #{file} -o #{dir}/#{basename}.pcm-1.tmp.wav -s #{Rails.root}/lib/audio_watermark/setup_0.txt -PCMC1 -KFILE #{Rails.root}/lib/audio_watermark/key.txt")
      end
      unless FileTest.exist?("#{dir}/#{basename}.mcf")
        @shell.execute("container_V3 pcm -i0 #{dir}/#{basename}.pcm-0.tmp.wav -i1 #{dir}/#{basename}.pcm-1.tmp.wav -io #{file} -setup #{Rails.root}/lib/audio_watermark/setup_0.txt -o #{dir}/#{basename}.mcf -ADPCM")
      end
      if TEST_WATERMARK
        @shell.execute("shuffle_V3 pcm -i #{dir}/#{basename}.mcf -o #{dir}/#{basename}.test_watermark.wav -wz #{sprintf("%032b", 54354444)} -md5 -sprt 48000 -btdp 16")
        @shell.execute("pcm-watermark retrieve -i #{dir}/#{basename}.test_watermark.wav -s #{Rails.root}/lib/audio_watermark/setup_0.txt -RMF /tmp/pcm-recovery-log.txt -KFILE #{Rails.root}/lib/audio_watermark/key.txt -PCMC0")
      end
    end
  end
  
  desc "rename all"
  task(:rename_all => :environment) do
    [Dir["/var/content/imports/Streamburst/video/*"],
     Dir["/var/content/imports/Streamburst/audio/*"]].each do |folder|
      folder.each do |file|
        pathname = Pathname.new(file)
        dir = pathname.dirname.to_s
        basename = pathname.basename.to_s
        if basename.include?(".h264") or basename.include?(".wav")
          program_id = basename[0..2].to_i
          episode = lookup_names(program_id)
          if basename.include?(".wav")
            if basename.include?("French")
              locale = "fr"
            elsif basename.include?("Spanish")
              locale = "es"
            elsif basename.include?("5&6is")
              locale = "is"
            elsif basename.include?("1&2en")
              locale = "en"
            end
            system "mv \"#{file}\" \"#{dir}/#{episode[:base_filename]}-#{locale}.wav\""
          else
            if basename.include?("_26.")
              system "mv \"#{file}\" \"#{dir}/26/#{episode[:base_filename]}-HQ-en.h264\""
            elsif basename.include?("_24.")
              system "mv \"#{file}\" \"#{dir}/24/#{episode[:base_filename]}-Portable-en.h264\""
            end
          end
        end
      end
    end
  end

  desc "encode video"
  task(:encode_video => :environment) do
    h264_track_id = 2
    @shell = Shell.new
    Dir["/var/content/imports/Streamburst/video/*.mov"].each do |infile|
      puts "processing: #{infile}"
      cleanup = []
      pathname = Pathname.new(infile)
      dir = pathname.dirname.to_s      
      basename = pathname.basename.to_s
      basename_no_ext_original = basename[0..basename.length-5]
      basename_no_ext = basename_no_ext_original.gsub(" ","_").gsub(".","")
      cleanup << infile_h264 = "#{dir}/#{basename_no_ext_original}_track2.h264"
      @shell.execute("MP4BoxNew -raw \"#{h264_track_id}\" \"#{infile}\"")
      [Format.find(26),Format.find(24)].each do |f|
        cleanup << file_y4m = "#{dir}/#{basename_no_ext}_#{f.id}.y4m"
        @shell.execute("ffmpeg -i \"#{infile_h264}\" -s #{f.px_width}x#{f.px_height} \"#{file_y4m}\"")
        outfile_h264 = "#{dir}/#{basename_no_ext.gsub(" ","_")}_#{f.id}.h264"
        cleanup << stats = "#{dir}/#{basename_no_ext}_#{f.id}.stats"
        @shell.execute("x264_1153 --pass 1 --stats \"#{stats}\" #{f.pass_1_video_codec_options} --output NUL \"#{file_y4m}\" #{f.px_width}x#{f.px_height}")
        @shell.execute("x264_1153 --pass 2 --stats \"#{stats}\" #{f.pass_2_video_codec_options} --output \"#{outfile_h264}\" \"#{file_y4m}\" #{f.px_width}x#{f.px_height}")
      end
      cleanup.each do |f| File.delete(f) end
    end
  end
end
