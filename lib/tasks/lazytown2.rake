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

def lookup_names(program_id)
  name_file = File.open("/home/robert/lazytown_2_imports/names.csv","r")
  FasterCSV.parse(name_file.read) do |row|
    if row[0].to_i==program_id
      return {:program_id=>row[0].to_i, :running_order=>row[1].to_i, :name_en=>row[2].strip,
              :name_is=>row[3].strip, :name_es=>row[4].strip, :name_fr=>row[5].strip,
              :base_filename=>"LazyTown-S2-#{row[1]}-#{row[2].gsub(" ","-")}" }
      break
    end
  end  
end

def all_names
  name_file = File.open("/home/robert/lazytown_2_imports/names.csv","r")
  out = []
  FasterCSV.parse(name_file.read) do |row|
    out << {:program_id=>row[0].to_i, :running_order=>row[1].to_i, :name_en=>row[2].strip,
            :name_is=>row[3].strip, :name_es=>row[4].strip, :name_fr=>row[5].strip,
            :base_filename=>"LazyTown-S2-#{row[1]}-#{row[2].gsub(" ","-")}" }
  end
  out
end

def import_downloads(locale_filter)
  all_downloads = []
  all_names.each do |entry|   
    download = ProductDownload.new
    download.hq_filename = "#{entry[:base_filename]}-HQ-#{locale_filter}.mp4"
    download.portable_filename = "#{entry[:base_filename]}-Portable-#{locale_filter}.mp4"
    download.timelength = (23*60)+32
    download.program_id = entry[:running_order]
    download.production_code = entry[:program_id]
    download.locale_filter = locale_filter
    download.product_name = entry["name_#{locale_filter}".to_sym]
    all_downloads << download
  end
  puts all_downloads.inspect
  all_downloads
end

namespace :lazytown2 do
  desc "Set download file sizes"
  task(:set_download_file_sizes => :environment) do
    @brand = Brand.find_by_name("LazyTown")
    Product.find_all_by_brand_id(@brand.id).each do |product|
      product.product_formats.each do |product_format|
        if product_format.format.id==26
          download = product_format.download
          puts file_to_test = "/var/content/originals/13/18/26/#{download.file_name[0..download.file_name.length-5]}.h264"
          puts download.file_size_mb = ((File.size(file_to_test)/1024/1024)*1.1082).to_i
          download.save
        elsif product_format.format.id==24
          download = product_format.download
          puts file_to_test = "/var/content/originals/13/18/24/#{download.file_name[0..download.file_name.length-5]}.h264"          
          puts download.file_size_mb = ((File.size(file_to_test)/1024/1024)*1.21).to_i
          download.save
        end
      end
    end
  end
end

namespace :lazytown2 do
  desc "Create wm cache target"
  task(:create_wm_cache_target => :environment) do
    @brand = Brand.find_by_name("LazyTown")
    WatermarkCacheTarget.destroy_all if RAILS_ENV=="development"
    Product.find_all_by_brand_id(@brand.id).each do |product|
      product.product_formats.each do |product_format|
        if product_format.format.id==26 or product_format.format.id==24
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

namespace :lazytown2 do
  desc "Create LazyTown Symlinks"
  task(:create_sym_links => :environment) do
    puts "Create symlinks for Portable MCF"
    ["en","es","fr","is"].each do |locale_filter|
      all_names.each do |entry|
        base_name = "#{entry[:base_filename]}-#{locale_filter}.mcf"
        hq_name = "#{entry[:base_filename]}-HQ-#{locale_filter}.mcf"
        portable_name = "#{entry[:base_filename]}-Portable-#{locale_filter}.mcf"
        system "ln -s /var/content/originals/13/18/26/#{base_name} /var/content/originals/13/18/26/#{hq_name}"
        system "ln -s /var/content/originals/13/18/26/#{base_name} /var/content/originals/13/18/24/#{portable_name}"
      end
    end

    puts "Create symlinks for H264"
    ["es","fr","is"].each do |locale_filter|
      all_names.each do |entry|
        [[26,"HQ"],[24,"Portable"]].each do |format|
          in_name = "#{entry[:base_filename]}-#{format[1]}-en.h264"
          out_name = "#{entry[:base_filename]}-#{format[1]}-#{locale_filter}.h264"
          system "ln -s /var/content/originals/13/18/#{format[0]}/#{in_name} /var/content/originals/13/18/#{format[0]}/#{out_name}"
        end
      end
    end
  end
end

namespace :lazytown2 do
  desc "Create LazyTown Offers"
  task(:step_3_create_offers => :environment) do

    @lazytown_offer_bundle = PriceClass.new
    @lazytown_offer_bundle.name = "LazyTown S2 Offer Bundle"
    @lazytown_offer_bundle.price_usd = 4.77
    @lazytown_offer_bundle.price_gbp = 4.53
    @lazytown_offer_bundle.price_eur = 4.77
    @lazytown_offer_bundle.price_isk = 609.0
    @lazytown_offer_bundle.save
    
    @lazytown_offer_all_episodes = PriceClass.new
    @lazytown_offer_all_episodes.name = "LazyTown Offer All Episodes"
    @lazytown_offer_all_episodes.price_usd = 25.07
    @lazytown_offer_all_episodes.price_gbp = 23.81
    @lazytown_offer_all_episodes.price_eur = 25.07
    @lazytown_offer_all_episodes.price_isk = 3170.0
    @lazytown_offer_all_episodes.save

#    ["en","es","fr","is"].each do |locale|
    ["en","es","fr"].each do |locale|
      I18n.locale = locale
  
      bundle = {:program_id=>1, :discount=>30, :locale=>locale, :title=>"#{I18n.translate :All_Seasion_1_Episodes}", :episodes=>(1..18).to_a}
      create_offer_product(bundle, @lazytown_offer_all_episodes.id) 
  
      bundle = {:program_id=>2, :discount=>20, :locale=>locale, :title=>"#{I18n.translate :Bundle} 1", :episodes=>[1,2,3]}
      create_offer_product(bundle, @lazytown_offer_bundle.id) 
  
      bundle = {:program_id=>3, :discount=>20, :locale=>locale, :title=>"#{I18n.translate :Bundle} 2", :episodes=>[4,5,6]}
      create_offer_product(bundle, @lazytown_offer_bundle.id) 
  
      bundle = {:program_id=>4, :discount=>20, :locale=>locale, :title=>"#{I18n.translate :Bundle} 3", :episodes=>[7,8,9]}
      create_offer_product(bundle, @lazytown_offer_bundle.id) 
  
      bundle = {:program_id=>5, :discount=>20, :locale=>locale, :title=>"#{I18n.translate :Bundle} 4", :episodes=>[10,11,12]}
      create_offer_product(bundle, @lazytown_offer_bundle.id) 
  
      bundle = {:program_id=>6, :discount=>20, :locale=>locale, :title=>"#{I18n.translate :Bundle} 5", :episodes=>[13,14,15]}
      create_offer_product(bundle, @lazytown_offer_bundle.id) 
  
      bundle = {:program_id=>7, :discount=>20, :locale=>locale, :title=>"#{I18n.translate :Bundle} 6", :episodes=>[16,17,18]}
      create_offer_product(bundle, @lazytown_offer_bundle.id)
    end
  end
end

def create_offer_product(bundle, price_class_id)
  I18n.locale = bundle[:locale]
  @company = Company.find_by_name "LazyTown Entertainment"  
  @brand = Brand.find_by_name "LazyTown"
  @category_offers = Category.find_by_name "Season 2 Offers"
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
      child_product = Product.find_by_program_id(episode,:first, :joins=>:categories, :conditions=>"brand_id = 18 AND categories.id = 25 AND locale_filter = '#{bundle[:locale]}'")
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

namespace :lazytown2 do
  desc "Import and Create LazyTown Video Products"
  task(:step_1_import_and_create_video_products => :environment) do
    @company = Company.find_by_name "LazyTown Entertainment"    
    @brand = Brand.find_by_name "LazyTown"

    @category_s1_episodes = Category.new
    @category_s1_episodes.name = "Season 1"
    @category_s1_episodes.save

    @category_s2_episodes = Category.new
    @category_s2_episodes.name = "Season 2"
    @category_s2_episodes.save

    @category_s1_offers = Category.find_by_name "Offers"
    if @category_s1_offers
      @category_s1_offers.name = "Season 1 Offers"
      @category_s1_offers.save
    end
    @category_s2_offers = Category.new
    @category_s2_offers.name = "Season 2 Offers"
    @category_s2_offers.save
    
    localhost = Host.find_by_name("localhost")
    localhost.brands << @brand if RAILS_ENV=="development"

    app2 = Host.find_by_name("app2.streamburst.net")
    unless app2
      app2 = Host.new
      app2.name = "app2.streamburst.net"
      app2.save if RAILS_ENV=="development"
    end
    app2.brands << @brand if RAILS_ENV=="development"
    
    Product.find_all_by_brand_id(@brand.id).each do |product|
      product.categories.each do |c|
        if c.id==1
          product.categories.delete(Category.find(1))
          product.categories<<@category_s1_episodes
          break
        end
      end
    end

    unless Format.exists?(26)
      f=Format.find(23).clone
      f.px_width=736
      f.px_height=414
      f.save
    end
    
    @format_26 = Format.find(26)
    @format_24 = Format.find(24)

    @lazytown_price_free = PriceClass.find_by_name "LazyTown Free"
    @lazytown_price_free.price_isk = 0
    @lazytown_price_free.save


    @lazytown_episode = PriceClass.find_by_name "LazyTown Episode"
    @lazytown_episode.price_isk = 259
    @lazytown_episode.save

    @lazytown_offer_bundle = PriceClass.find_by_name "LazyTown Offer Bundle"
    @lazytown_offer_bundle.price_isk = 999
    @lazytown_offer_bundle.save
    
    @lazytown_offer_all_episodes = PriceClass.find_by_name "LazyTown Offer All Episodes"
    @lazytown_offer_all_episodes.price_isk = 6400
    @lazytown_offer_all_episodes.save

    @lazytown_offer_all_songs = PriceClass.find_by_name "LazyTown Offer All Songs"
    @lazytown_offer_all_songs.price_isk = 1400
    @lazytown_offer_all_songs.save

    @lazytown_offer_all = PriceClass.find_by_name "LazyTown Offer All"
    @lazytown_offer_all.price_isk = 7700
    @lazytown_offer_all.save

    @lazytown_songs_price_class = PriceClass.find_by_name "LazyTown Songs"
    @lazytown_songs_price_class.price_isk = 129
    @lazytown_songs_price_class.save
    
    p=Product.find(274)
    p.description = p.description.gsub("40%","45%")
    p.save
    
    (275..283).each do |id|
      p=Product.find(id)
      p.description = p.description.gsub("20%","22%")
      p.save      
    end

#    ["is","en","es","fr"].each do |locale|
    ["en","es","fr"].each do |locale|
      import_downloads(locale).each do |download|
        product = Product.new
        product.title = download.product_name
        product.description = download.product_name
        product.short_title = download.product_name
        product.duration = download.timelength
        product.program_id = download.program_id
        product.company_id = @company.id
        product.brand_id = @brand.id
        product.price_class_id = @lazytown_episode.id
        product.active = true
        product.source_format = ""
        product.master_filename = ""
        product.use_audio_watermarking = true
        product.watch_now_filename = ""
        product.audio_only = false
        product.locale_filter = locale
        file_handle = File.open("/home/robert/lazytown_imports/LT_EPISODE_PNGs/#{download.production_code}.png", "r")
        #file_handle = File.open("/home/robert/lazytown_imports/lt_offer_image.png", "r")
        product.flv_preview_url =  "http://flv.streamburst.tv/lazytown/previews/#{download.production_code}.flv"
        product.image = file_handle
        product.save(false)
        puts product.inspect

        product.categories << @category_s2_episodes

        hq_download = Download.new
        hq_download.active = true
        hq_download.file_name = download.hq_filename
        hq_download.save
  
        portable_download = Download.new
        portable_download.active = true
        portable_download.file_name = download.portable_filename
        portable_download.save
  
        product_format = ProductFormat.new
        product_format.format_id = @format_26.id
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
