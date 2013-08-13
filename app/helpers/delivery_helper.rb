class Array
  def random(weights=nil)
    return random(map {|n| n.send(weights)}) if weights.is_a? Symbol
    weights ||= Array.new(length, 1.0)
    total = weights.inject(0.0) {|t,w| t+w}
    point = Kernel::rand * total
   
    zip(weights).each do |n,w|
    return n if w >= point
      point -= w
    end
  end
end

module DeliveryHelper
  def getCoverArtworkDownloadUrl(file_name)
    "http://flv.streamburst.tv/cover_artwork/#{file_name}"
  end

  def get_file_size(file_name, company_id, brand_id, format_id, audio_only)
    begin
#      logger.info("/var/content/originals/#{company_id}/#{brand_id}/#{format_id}/#{file_name}")
      if audio_only
        size_in_bytes = File.size("/var/content/originals/#{company_id}/#{brand_id}/#{format_id}/#{file_name[0..file_name.length-5]}.mcf") / 2
      elsif File.exists?("/var/content/originals/#{company_id}/#{brand_id}/#{format_id}/#{file_name}")
        size_in_bytes = File.size("/var/content/originals/#{company_id}/#{brand_id}/#{format_id}/#{file_name}")
      else
        unless File.exists?("/var/content/originals/#{company_id}/#{brand_id}/#{format_id}/#{file_name}.h264")
          h_264_size_in_bytes = File.size("/var/content/originals/#{company_id}/#{brand_id}/#{format_id}/#{file_name}.h264")
          aac_size_in_bytes = File.size("/var/content/originals/#{company_id}/#{brand_id}/#{format_id}/#{file_name}.aac")
          size_in_bytes = h_264_size_in_bytes + aac_size_in_bytes
        else
          xvid_size_in_bytes = File.size("/var/content/originals/#{company_id}/#{brand_id}/#{format_id}/#{file_name}.xvid")
          aac_size_in_bytes = File.size("/var/content/originals/#{company_id}/#{brand_id}/#{format_id}/#{file_name}.aac")
          size_in_bytes = xvid_size_in_bytes + aac_size_in_bytes
        end
      end
      if size_in_bytes && size_in_bytes > 0
        size_in_bytes/1024/1024
      else
        -1
      end
    rescue
#      logger.error("Couldnt find size")
    end
  end
end
