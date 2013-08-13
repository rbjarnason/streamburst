require 'rubygems'
require 'fastercsv'
require 'ftools'
require 'yaml'
 
class Hash
  # Replacing the to_yaml function so it'll serialize hashes sorted (by their keys)
  # Original function is in /usr/lib/ruby/1.8/yaml/rubytypes.rb
  def to_yaml( opts = {} )
    YAML::quick_emit( object_id, opts ) do |out|
      ouproduct.map( taguri, to_yaml_style ) do |map|
        sorproduct.each do |k, v|   # <-- here's my addition (the 'sort')
          map.add( k, v )
        end
      end
    end
  end
end

class ProductDownload
  attr_accessor :hq_filename, :portable_filename, :product_name, :timelength, 
                :program_id, :locale_filter, :old_is_source, :mp3_160_filename, 
                :mp3_320_filename, :mp3_preview_filename, :wav_filename, :production_code
  
  def get_hq_format_id
    23
  end

 def get_portable_format_id
    24
  end
end

def lookup_dvd_id(from_col, to_lang, to_col, dvd_id)
  translate_file = File.open("/home/robert/lazytown_imports/translate.csv","r")
  out_dvd_id = ""
  FasterCSV.parse(translate_file.read) do |row|
    if row[from_col] and row[from_col]==dvd_id.gsub(".",":")
      out_dvd_id = row[to_col]
      break
    end
  end
  if out_dvd_id
    to_lang+"-"+out_dvd_id.gsub(":",".")
  else
    nil
  end
end

def lookup_is_h264_filenames(is_infile, is_source_id)
  out_filenames = Hash.new
  f = File.open(is_infile)
  content_all_hash = YAML.load(f)
  f.close
  content_all_hash.each do |id, entry|
    if entry["source"]==is_source_id and entry["filename"][entry["filename"].length-2..entry["filename"].length]=="HQ"
      out_filenames["HQ"] = "#{entry['filename']}.h264"
      out_filenames["Portable"] = "#{entry['filename'][0..entry['filename'].length-4]}-Portable.h264"
      break
    end
  end
  out_filenames
end

def import_downloads(file_name,locale_filter)
  all_downloads = Hash.new
  f = File.open(file_name)
  content_all_hash = YAML.load(f)
  f.close
  content_all_hash.each do |id, entry|
    if entry["filename"][entry["filename"].length-2..entry["filename"].length]=="HQ"
      download = all_downloads[entry['name']]
      if download
        puts "ERROR Double Download"
        break
      end
      download = ProductDownload.new
      download.hq_filename = "#{entry['filename']}.mp4"
      download.portable_filename = "#{entry['filename'][0..entry['filename'].length-4]}-Portable.mp4"
      download.timelength = (entry["min"].to_i*60)+entry["sec"]
      download.program_id = entry["program_id"]
      download.production_code = entry["production_code"]
      download.locale_filter = locale_filter
      download.product_name = entry["name"]
      download.old_is_source = entry["old_is_source"]
      all_downloads[entry['name']] = download
    end
  end
  all_downloads
end

def import_music_downloads(file_name,locale_filter)
  all_downloads = Hash.new
  f = File.open(file_name)
  content_all_hash = YAML.load(f)
  f.close
  content_all_hash.each do |id, entry|
    download = all_downloads[entry['name']]
    if download
      puts "ERROR Double Download"
      break
    end
    download = ProductDownload.new
    download.mp3_160_filename = "#{entry['filename']}.mp3"
    download.mp3_320_filename = "#{entry['filename']}-HQ.mp3"
    download.mp3_preview_filename = "http://flv.streamburst.tv/lazytown/mp3/#{entry['filename']}-160-Preview.mp3"
    download.wav_filename = "#{entry['filename']}.wav"
    download.timelength = (entry["min"].to_i*60)+entry["sec"]
    download.program_id = entry["program_id"]
    download.locale_filter = locale_filter
    download.product_name = entry["name"]
    all_downloads[entry['name']] = download
  end
  all_downloads
end

namespace :lazytown do
  desc "Set download file sizes"
  task(:set_download_file_sizes => :environment) do
    @brand = Brand.find_by_name("LazyTown")
    Product.find_all_by_brand_id(@brand.id).each do |product|
      product.product_formats.each do |product_format|
        if product_format.format.id==23
          download = product_format.download
          puts file_to_test = "/var/content/originals/13/18/23/#{download.file_name[0..download.file_name.length-5]}.h264"
          puts download.file_size_mb = ((File.size(file_to_test)/1024/1024)*1.1082).to_i
          download.save
        elsif product_format.format.id==24
          download = product_format.download
          puts file_to_test = "/var/content/originals/13/18/24/#{download.file_name[0..download.file_name.length-5]}.h264"          
          puts download.file_size_mb = ((File.size(file_to_test)/1024/1024)*1.21).to_i
          download.save
        elsif product_format.format.id==12
          download = product_format.download
          puts file_to_test = "/var/content/direct/13/18/12/#{download.file_name}"          
          puts download.file_size_mb = (File.size(file_to_test)/1024/1024).to_i
          download.save
        elsif product_format.format.id==20
          download = product_format.download
          puts file_to_test = "/var/content/direct/13/18/20/#{download.file_name}"          
          puts download.file_size_mb = (File.size(file_to_test)/1024/1024).to_i
          download.save
        elsif product_format.format.id==22
          download = product_format.download
          puts file_to_test = "/var/content/direct/13/18/22/#{download.file_name}"          
          puts download.file_size_mb = (File.size(file_to_test)/1024/1024).to_i
          download.save
        end
      end
    end
  end
end

namespace :lazytown do
  desc "Create wm cache target"
  task(:create_wm_cache_target => :environment) do
    @brand = Brand.find_by_name("LazyTown")
    WatermarkCacheTarget.destroy_all if RAILS_ENV=="development"
    Product.find_all_by_brand_id(@brand.id).each do |product|
      product.product_formats.each do |product_format|
        if product_format.format.id==23 or product_format.format.id==24
          wm = WatermarkCacheTarget.new
          wm.download_id = product_format.download.id
          wm.weight = 400
          wm.max_per_cache_server = RAILS_ENV=="development" ? 1 : 2
          wm.audio_watermark_enabled = true
          wm.video_watermark_enabled = false
          wm.cache_type = "mp4"
          wm.save
          puts wm.inspect
        end
      end
    end
  end
end


namespace :lazytown do
  desc "Create LazyTown Symlinks"
  task(:create_sym_links => :environment) do
    puts "Create IS symlinks for Portable MCF"
    import_downloads("/home/robert/lazytown_imports/lt_is_all.yml", "is").each do |key, download|
      in_filename = "#{download.hq_filename[0..download.hq_filename.length-5]}.mcf"
      out_filename = "#{download.portable_filename[0..download.portable_filename.length-5]}.mcf"     
      system "ln -s /var/content/originals/13/18/23/#{in_filename} /var/content/originals/13/18/24/#{out_filename}"
    end
    
    puts "Create US symlinks for HQ and Portable H264"
    import_downloads("/home/robert/lazytown_imports/lt_en_all.yml", "is").each do |key, download|
      filenames = lookup_is_h264_filenames("/home/robert/lazytown_imports/lt_is_all.yml", download.old_is_source)
      in_filename = filenames["HQ"]
      out_filename = "#{download.hq_filename[0..download.hq_filename.length-5]}.h264"
      system "ln -s /var/content/originals/13/18/23/#{in_filename} /var/content/originals/13/18/23/#{out_filename}"

      in_filename = filenames["Portable"]
      out_filename = "#{download.portable_filename[0..download.portable_filename.length-5]}.h264"
      system "ln -s /var/content/originals/13/18/24/#{in_filename} /var/content/originals/13/18/24/#{out_filename}"
    end

    puts "Create US symlinks for Portable MCF"
    import_downloads("/home/robert/lazytown_imports/lt_en_all.yml", "en").each do |key, download|
      in_filename = "#{download.hq_filename[0..download.hq_filename.length-5]}.mcf"
      out_filename = "#{download.portable_filename[0..download.portable_filename.length-5]}.mcf"     
      system "ln -s /var/content/originals/13/18/23/#{in_filename} /var/content/originals/13/18/24/#{out_filename}"
    end

    puts "Create ES symlinks for HQ and Portable H264"
    import_downloads("/home/robert/lazytown_imports/lt_es_all.yml", "is").each do |key, download|
      filenames = lookup_is_h264_filenames("/home/robert/lazytown_imports/lt_is_all.yml", download.old_is_source)
      in_filename = filenames["HQ"]
      out_filename = "#{download.hq_filename[0..download.hq_filename.length-5]}.h264"
      system "ln -s /var/content/originals/13/18/23/#{in_filename} /var/content/originals/13/18/23/#{out_filename}"

      in_filename = filenames["Portable"]
      out_filename = "#{download.portable_filename[0..download.portable_filename.length-5]}.h264"
      system "ln -s /var/content/originals/13/18/24/#{in_filename} /var/content/originals/13/18/24/#{out_filename}"
    end

    puts "Create ES symlinks for Portable MCF"
    import_downloads("/home/robert/lazytown_imports/lt_es_all.yml", "en").each do |key, download|
      in_filename = "#{download.hq_filename[0..download.hq_filename.length-5]}.mcf"
      out_filename = "#{download.portable_filename[0..download.portable_filename.length-5]}.mcf"     
      system "ln -s /var/content/originals/13/18/23/#{in_filename} /var/content/originals/13/18/24/#{out_filename}"
    end

  end
end

namespace :lazytown do
  desc "Create LazyTown Offers"
  task(:step_3_create_offers => :environment) do

    # IS and EN

    @lazytown_offer_bundle = PriceClass.new
    @lazytown_offer_bundle.name = "LazyTown Offer Bundle"
    @lazytown_offer_bundle.price_usd = 7.95
    @lazytown_offer_bundle.price_gbp = 7.31
    @lazytown_offer_bundle.price_eur = 7.95
    @lazytown_offer_bundle.save
    
    @lazytown_offer_all_episodes = PriceClass.new
    @lazytown_offer_all_episodes.name = "LazyTown Offer All Episodes"
    @lazytown_offer_all_episodes.price_usd = 49.25
    @lazytown_offer_all_episodes.price_gbp = 46.78
    @lazytown_offer_all_episodes.price_eur = 49.25
    @lazytown_offer_all_episodes.save

    @lazytown_offer_all_songs = PriceClass.new
    @lazytown_offer_all_songs.name = "LazyTown Offer All Songs"
    @lazytown_offer_all_songs.price_usd = 11.29
    @lazytown_offer_all_songs.price_gbp = 9.01
    @lazytown_offer_all_songs.price_eur = 11.29
    @lazytown_offer_all_songs.save

    @lazytown_offer_all = PriceClass.new
    @lazytown_offer_all.name = "LazyTown Offer All"
    @lazytown_offer_all.price_usd = 59.14
    @lazytown_offer_all.price_gbp = 54.17
    @lazytown_offer_all.price_eur = 59.14
    @lazytown_offer_all.save
    
    # ES

    @lazytown_offer_bundle_es = PriceClass.new
    @lazytown_offer_bundle_es.name = "LazyTown Offer Bundle ES"
    @lazytown_offer_bundle_es.price_usd = 7.15
    @lazytown_offer_bundle_es.price_gbp = 6.43
    @lazytown_offer_bundle_es.price_eur = 7.15
    @lazytown_offer_bundle_es.save

    @lazytown_offer_all_episodes_es = PriceClass.new
    @lazytown_offer_all_episodes_es.name = "LazyTown Offer All Episodes ES"
    @lazytown_offer_all_episodes_es.price_usd = 25.37
    @lazytown_offer_all_episodes_es.price_gbp = 24.10
    @lazytown_offer_all_episodes_es.price_eur = 25.37
    @lazytown_offer_all_episodes_es.save

    @lazytown_offer_all_songs_es = PriceClass.new
    @lazytown_offer_all_songs_es.name = "LazyTown Offer All Songs ES"
    @lazytown_offer_all_songs_es.price_usd = 11.88
    @lazytown_offer_all_songs_es.price_gbp = 9.48
    @lazytown_offer_all_songs_es.price_eur = 11.88
    @lazytown_offer_all_songs_es.save

    @lazytown_offer_all_es = PriceClass.new
    @lazytown_offer_all_es.name = "LazyTown Offer All ES"
    @lazytown_offer_all_es.price_usd = 37.54
    @lazytown_offer_all_es.price_gbp = 33.55
    @lazytown_offer_all_es.price_eur = 37.54
    @lazytown_offer_all_es.save

    I18n.locale = "is"

    bundle = {:program_id=>1, :discount=>30, :locale=>"is", :title=>"#{I18n.translate :All_Seasion_1}", :episodes=>(1..34).to_a, :songs=>(1..20).to_a}
    create_offer_product(bundle, @lazytown_offer_all.id) 

    bundle = {:program_id=>2, :discount=>25, :locale=>"is", :title=>"#{I18n.translate :All_Seasion_1_Episodes}", :episodes=>(1..34).to_a}
    create_offer_product(bundle, @lazytown_offer_all_episodes.id) 

    bundle = {:program_id=>3, :discount=>40, :locale=>"is", :title=>"#{I18n.translate :All_Seasion_1_Songs}", :songs=>(1..20).to_a}
    create_offer_product(bundle, @lazytown_offer_all_songs.id)

    bundle = {:program_id=>4, :discount=>20, :locale=>"is", :title=>"#{I18n.translate :Bundle} 1", :episodes=>[1,2,3,4], :songs=>[1,2,3]}
    create_offer_product(bundle, @lazytown_offer_bundle.id) 

    bundle = {:program_id=>5, :discount=>20, :locale=>"is", :title=>"#{I18n.translate :Bundle} 2", :episodes=>[5,6,7,8], :songs=>[4,5]}
    create_offer_product(bundle, @lazytown_offer_bundle.id) 

    bundle = {:program_id=>6, :discount=>20, :locale=>"is", :title=>"#{I18n.translate :Bundle} 3", :episodes=>[9,10,11,12], :songs=>[6,7]}
    create_offer_product(bundle, @lazytown_offer_bundle.id) 

    bundle = {:program_id=>7, :discount=>20, :locale=>"is", :title=>"#{I18n.translate :Bundle} 4", :episodes=>[13,14,15], :songs=>[8,9]}
    create_offer_product(bundle, @lazytown_offer_bundle.id) 

    bundle = {:program_id=>8, :discount=>20, :locale=>"is", :title=>"#{I18n.translate :Bundle} 5", :episodes=>[16,17,18,19], :songs=>[10,11]}
    create_offer_product(bundle, @lazytown_offer_bundle.id) 

    bundle = {:program_id=>9, :discount=>20, :locale=>"is", :title=>"#{I18n.translate :Bundle} 6", :episodes=>[20,21,22,23], :songs=>[12,13]}
    create_offer_product(bundle, @lazytown_offer_bundle.id) 

    bundle = {:program_id=>10, :discount=>20, :locale=>"is", :title=>"#{I18n.translate :Bundle} 7", :episodes=>[24,25,26,27], :songs=>[14,15]}
    create_offer_product(bundle, @lazytown_offer_bundle.id) 

    bundle = {:program_id=>11, :discount=>20, :locale=>"is", :title=>"#{I18n.translate :Bundle} 8", :episodes=>[28,29,30,31], :songs=>[16,17]}
    create_offer_product(bundle, @lazytown_offer_bundle.id) 

    bundle = {:program_id=>12, :discount=>20, :locale=>"is", :title=>"#{I18n.translate :Bundle} 9", :episodes=>[32,33,34], :songs=>[18,19,20]}
    create_offer_product(bundle, @lazytown_offer_bundle.id) 

    I18n.locale = "en"

    bundle = {:program_id=>1, :discount=>30, :locale=>"en", :title=>"#{I18n.translate :All_Seasion_1}", :episodes=>(1..34).to_a, :songs=>(1..20).to_a}
    create_offer_product(bundle, @lazytown_offer_all.id)

    bundle = {:program_id=>2, :discount=>25, :locale=>"en", :title=>"#{I18n.translate :All_Seasion_1_Episodes}", :episodes=>(1..34).to_a}
    create_offer_product(bundle, @lazytown_offer_all_episodes.id) 

    bundle = {:program_id=>3, :discount=>40, :locale=>"en", :title=>"#{I18n.translate :All_Seasion_1_Songs}", :songs=>(1..20).to_a}
    create_offer_product(bundle, @lazytown_offer_all_songs.id)

    bundle = {:program_id=>4, :discount=>20, :locale=>"en", :title=>"#{I18n.translate :Bundle} 1", :episodes=>[1,2,3,4], :songs=>[1,2,3]}
    create_offer_product(bundle, @lazytown_offer_bundle.id) 

    bundle = {:program_id=>5, :discount=>20, :locale=>"en", :title=>"#{I18n.translate :Bundle} 2", :episodes=>[5,6,7,8], :songs=>[4,5]}
    create_offer_product(bundle, @lazytown_offer_bundle.id) 

    bundle = {:program_id=>6, :discount=>20, :locale=>"en", :title=>"#{I18n.translate :Bundle} 3", :episodes=>[9,10,11,12], :songs=>[6,7]}
    create_offer_product(bundle, @lazytown_offer_bundle.id) 

    bundle = {:program_id=>7, :discount=>20, :locale=>"en", :title=>"#{I18n.translate :Bundle} 4", :episodes=>[13,14,15,16], :songs=>[8,9]}
    create_offer_product(bundle, @lazytown_offer_bundle.id) 

    bundle = {:program_id=>8, :discount=>20, :locale=>"en", :title=>"#{I18n.translate :Bundle} 5", :episodes=>[17,18,19,20], :songs=>[10,11]}
    create_offer_product(bundle, @lazytown_offer_bundle.id) 

    bundle = {:program_id=>9, :discount=>20, :locale=>"en", :title=>"#{I18n.translate :Bundle} 6", :episodes=>[21,22,23], :songs=>[12,13]}
    create_offer_product(bundle, @lazytown_offer_bundle.id) 

    bundle = {:program_id=>10, :discount=>20, :locale=>"en", :title=>"#{I18n.translate :Bundle} 7", :episodes=>[24,25,26,27], :songs=>[14,15]}
    create_offer_product(bundle, @lazytown_offer_bundle.id) 

    bundle = {:program_id=>11, :discount=>20, :locale=>"en", :title=>"#{I18n.translate :Bundle} 8", :episodes=>[28,29,30,31], :songs=>[16,17]}
    create_offer_product(bundle, @lazytown_offer_bundle.id) 

    bundle = {:program_id=>12, :discount=>20, :locale=>"en", :title=>"#{I18n.translate :Bundle} 9", :episodes=>[32,33,34], :songs=>[18,19,20]}
    create_offer_product(bundle, @lazytown_offer_bundle.id) 

    I18n.locale = "es"

    bundle = {:program_id=>1, :discount=>30, :locale=>"es", :title=>"#{I18n.translate :All_Seasion_1}", :episodes=>(1..18).to_a, :songs=>(1..21).to_a}
    create_offer_product(bundle, @lazytown_offer_all_es.id) 

    bundle = {:program_id=>2, :discount=>25, :locale=>"es", :title=>"#{I18n.translate :All_Seasion_1_Episodes}", :episodes=>(1..18).to_a}
    create_offer_product(bundle, @lazytown_offer_all_episodes_es.id) 

    bundle = {:program_id=>3, :discount=>40, :locale=>"es", :title=>"#{I18n.translate :All_Seasion_1_Songs}", :songs=>(1..21).to_a}
    create_offer_product(bundle, @lazytown_offer_all_songs_es.id)

    bundle = {:program_id=>4, :discount=>20, :locale=>"es", :title=>"#{I18n.translate :Bundle} 1", :episodes=>[1,2,3], :songs=>[1,2,3,4]}
    create_offer_product(bundle, @lazytown_offer_bundle_es.id)

    bundle = {:program_id=>5, :discount=>20, :locale=>"es", :title=>"#{I18n.translate :Bundle} 2", :episodes=>[4,5,6], :songs=>[5,6,7]}
    create_offer_product(bundle, @lazytown_offer_bundle_es.id) 

    bundle = {:program_id=>6, :discount=>20, :locale=>"es", :title=>"#{I18n.translate :Bundle} 3", :episodes=>[7,8,9], :songs=>[8,9,10]}
    create_offer_product(bundle, @lazytown_offer_bundle_es.id) 

    bundle = {:program_id=>7, :discount=>20, :locale=>"es", :title=>"#{I18n.translate :Bundle} 4", :episodes=>[10,11,12], :songs=>[11,12,13]}
    create_offer_product(bundle, @lazytown_offer_bundle_es.id) 

    bundle = {:program_id=>8, :discount=>20, :locale=>"es", :title=>"#{I18n.translate :Bundle} 5", :episodes=>[13,14,15], :songs=>[14,15,16]}
    create_offer_product(bundle, @lazytown_offer_bundle_es.id) 

    bundle = {:program_id=>9, :discount=>20, :locale=>"es", :title=>"#{I18n.translate :Bundle} 6", :episodes=>[16,17,18], :songs=>[17,18,19,20,21]}
    create_offer_product(bundle, @lazytown_offer_bundle_es.id) 
  end
end

def create_offer_product(bundle, price_class_id)
  I18n.locale = bundle[:locale]
  @company = Company.find_by_name "LazyTown Entertainment"  
  @brand = Brand.find_by_name "LazyTown"
  @category_offers = Category.find_by_name "Offers"
  product = Product.new
  if bundle[:episodes] and bundle[:songs]
    product.title = "#{bundle[:title]} - #{bundle[:episodes].length} #{I18n.translate :Episodes} #{I18n.translate :and} #{bundle[:songs].length} #{I18n.translate :Songs}" 
  elsif bundle[:episodes]
    product.title = "#{bundle[:title]} - #{bundle[:episodes].length} #{I18n.translate :Episodes}" 
  elsif bundle[:songs]
     product.title = "#{bundle[:title]} - #{bundle[:songs].length} #{I18n.translate :Songs}" 
  end
  product.description = ""
  product.short_title = product.title
  product.duration = 0
  product.program_id = bundle[:program_id]
  product.company_id = @company.id
  product.brand_id = @brand.id
  product.price_class_id = price_class_id
  product.active = true
  product.parent_flag = true
  product.source_format = ""
  product.master_filename = ""
  product.use_audio_watermarking = false
  product.watch_now_filename = ""
  product.audio_only = false
  product.locale_filter = bundle[:locale]
  file_handle = File.open("/home/robert/lazytown_imports/lt_offer_image.png", "r")
  product.image = file_handle
  product.flv_preview_url = ""
  product.direct_download = false
  product.save(false)
  puts product.title
  product.categories << @category_offers

  offer_details = "<br>"

  if bundle[:episodes]
    puts "EPISODES"
    offer_details+="<b>#{I18n.translate(:Episodes)}:</b><br>"
    bundle[:episodes].each_with_index do |episode,index|
      child_product = Product.find_by_program_id(episode,:first, :joins=>:categories, :conditions=>"brand_id = 18 AND categories.id = 1 AND locale_filter = '#{bundle[:locale]}'")
      if index+1==bundle[:episodes].length
        offer_details = offer_details[0..offer_details.length-3]
        offer_details+=" #{I18n.translate :and} #{child_product.title}"
      else
        offer_details+="#{child_product.title}, "
      end
      product.child_products.push(child_product)
      puts child_product.title
    end    
  end

  if bundle[:songs]
    puts "SONGS"
    offer_details+="<br><br>" if bundle[:episodes]
    offer_details+="<b>#{I18n.translate(:Songs)}:</b><br>"
    bundle[:songs].each_with_index do |episode,index|
      child_product = Product.find_by_program_id(episode,:first, :joins=>:categories, :conditions=>"brand_id = 18 AND categories.id = 20 AND locale_filter = '#{bundle[:locale]}'")
      if index+1==bundle[:songs].length
        offer_details = offer_details[0..offer_details.length-3]
        offer_details+=" #{I18n.translate :and} #{child_product.title}"
      else
        offer_details+="#{child_product.title}, "
      end
      product.child_products.push(child_product)
      puts child_product.title
    end
  end
  offer_details+="<br><br><b>#{I18n.translate(:Discount_compared_to_single_title_purchases)}: #{bundle[:discount]}%</b>"
  puts "DESCRIPTION"
  product.description = offer_details
  puts product.description
  product.save(false)
end

namespace :lazytown do
  desc "Import and Create LazyTown Music Products"
  task(:step_2_import_and_create_music_products => :environment) do
    @company = Company.find_by_name "LazyTown Entertainment"
    
    @brand = Brand.find_by_name "LazyTown"

    @category_songs = Category.find_by_name "Songs"
    
    @format_12 = Format.find(12)
    @format_20 = Format.find(20)
    @format_22 = Format.find(22)

    @lazytown_price_free = PriceClass.find_by_name("LazyTown Free")
    
    @lazytown_songs_price_class = PriceClass.new
    @lazytown_songs_price_class.name = "LazyTown Songs"
    @lazytown_songs_price_class.price_usd = 0.99
    @lazytown_songs_price_class.price_gbp = 0.79
    @lazytown_songs_price_class.price_eur = 0.99
    @lazytown_songs_price_class.save
   
    ["is","en","es"].each do |locale|
      import_music_downloads("/home/robert/lazytown_imports/lt_#{locale}_music.yml", locale).each do |key, download|
        product = Product.new
        product.title = download.product_name
        product.description = download.product_name
        product.short_title = download.product_name
        product.duration = download.timelength
        product.program_id = download.program_id
        product.company_id = @company.id
        product.brand_id = @brand.id
        product.price_class_id = download.program_id == 1 ? @lazytown_price_free.id : @lazytown_songs_price_class.id
        product.active = true
        product.source_format = ""
        product.master_filename = ""
        product.use_audio_watermarking = false
        product.watch_now_filename = ""
        product.audio_only = true
        product.locale_filter = locale
        file_handle = File.open("/home/robert/lazytown_imports/lt_music_image.png", "r")
        product.image = file_handle
        product.flv_preview_url = download.mp3_preview_filename
        product.direct_download = true
        product.save(false)
        puts product.inspect

        product.categories << @category_songs

        mp3_320_download = Download.new
        mp3_320_download.active = true
        mp3_320_download.file_name = download.mp3_320_filename
        mp3_320_download.save

        mp3_160_download = Download.new
        mp3_160_download.active = true
        mp3_160_download.file_name = download.mp3_160_filename
        mp3_160_download.save

        wav_download = Download.new
        wav_download.active = true
        wav_download.file_name = download.wav_filename
        wav_download.save
  
        product_format = ProductFormat.new
        product_format.format_id = @format_12.id
        product_format.download_id = mp3_320_download.id
        product_format.save
        product.product_formats << product_format

        product_format = ProductFormat.new
        product_format.format_id = @format_20.id
        product_format.download_id = mp3_160_download.id
        product_format.save
        product.product_formats << product_format

        product_format = ProductFormat.new
        product_format.format_id = @format_22.id
        product_format.download_id = wav_download.id
        product_format.save
        product.product_formats << product_format
      end
    end
  end
end

namespace :lazytown do
  desc "Import and Create LazyTown Video Products"
  task(:step_1_import_and_create_video_products => :environment) do
    @company = Company.new
    @company.name = "LazyTown Entertainment"
    @company.save
    
    @brand = Brand.new
    @brand.name = "LazyTown"
    @brand.company_id = @company.id
    @brand.layout_name = "lazytown"
    @brand.admin_layout_name = "streamburst_admin"
    @brand.global_brand_access = false
    @brand.cart_fade_start_color = "#436089"
    @brand.cart_fade_end_color = "#AAAAAA"
    @brand.page_background_color = "#FFFFFF"
    @brand.welcome_text_color = "#FFFFFF"
    @brand.welcome_text_background_color = "#FFFFFF"
    @brand.start_category_id = 1
    @brand.description = "LazyTown"
    @brand.dvm_main_help = "LazyTown"
    @brand.home_enabled = true
    @brand.custom_products_list = true
    @brand.filter_by_locale = true    
    @brand.checkout_confirm_on_top = true
    @brand.save
    
    @category_bundles = Category.find_by_name("Bundles")

    @category_songs = Category.find_by_name("Songs")

    @category_offers = Category.find_by_name("Offers")

    @category_episodes = Category.find(1)
    
    @format_23 = Format.find(23)
    @format_24 = Format.find(24)

    @lazytown_price_free = PriceClass.new
    @lazytown_price_free.name = "LazyTown Free"
    @lazytown_price_free.save

    @lazytown_episode = PriceClass.new
    @lazytown_episode.name = "LazyTown Episode"
    @lazytown_episode.price_usd = 1.99
    @lazytown_episode.price_gbp = 1.89
    @lazytown_episode.price_eur = 1.99
    @lazytown_episode.save
   
    localhost = Host.find_by_name("localhost")
    localhost.brands << @brand if RAILS_ENV=="development"

    app2 = Host.find_by_name("app2.streamburst.net")
    unless app2
      app2 = Host.new
      app2.name = "app2.streamburst.net"
      app2.save if RAILS_ENV=="development"
    end
    app2.brands << @brand if RAILS_ENV=="development"

    ["is","en","es"].each do |locale|
      import_downloads("/home/robert/lazytown_imports/lt_#{locale}_all.yml", locale).each do |key, download|
        product = Product.new
        product.title = download.product_name
        product.description = download.product_name
        product.short_title = download.product_name
        product.duration = download.timelength
        product.program_id = download.program_id
        product.company_id = @company.id
        product.brand_id = @brand.id
        product.price_class_id = download.program_id == 1 ? @lazytown_price_free.id : @lazytown_episode.id
        product.active = true
        product.source_format = ""
        product.master_filename = ""
        product.use_audio_watermarking = true
        product.watch_now_filename = ""
        product.audio_only = false
        product.locale_filter = locale
        file_handle = File.open("/home/robert/lazytown_imports/LT_EPISODE_PNGs/#{download.production_code}.png", "r")
        product.flv_preview_url =  "http://flv.streamburst.tv/lazytown/previews/#{download.production_code}.flv"
        product.image = file_handle
        product.save(false)
        puts product.inspect

        product.categories << @category_episodes

        hq_download = Download.new
        hq_download.active = true
        hq_download.file_name = download.hq_filename
        hq_download.save
  
        portable_download = Download.new
        portable_download.active = true
        portable_download.file_name = download.portable_filename
        portable_download.save
  
        product_format = ProductFormat.new
        product_format.format_id = @format_23.id
        product_format.download_id = hq_download.id
        product_format.save
        product.product_formats << product_format
  
        product_format = ProductFormat.new
        product_format.format_id = @format_24.id
        product_format.download_id = portable_download.id
        product_format.save
        product.product_formats << product_format
      end
    end
  end
end
