class AddWatermarkTargets < ActiveRecord::Migration
  def self.up
    @downloads = Download.find_all
    for d in @downloads
      if d.file_name[0..11] == "lwr_episode_" and d.file_name[d.file_name.length-6..d.file_name.length] == "hq.mp4"
        wt = WatermarkCacheTarget.new
        wt.max_per_cache_server = 5
        wt.download_id = d.id
        wt.weight = 150
        wt.cache_type = "mp4"
        wt.save
      elsif d.file_name[0..11] == "lwr_episode_" and d.file_name[d.file_name.length-12..d.file_name.length] == "portable.mp4"
        wt = WatermarkCacheTarget.new
        wt.max_per_cache_server = 2
        wt.download_id = d.id
        wt.weight = 70
        wt.cache_type = "mp4"
        wt.save
      elsif d.file_name[0..11] == "lwr_episode_" and d.file_name[d.file_name.length-10..d.file_name.length] == "mobile.mp4"
        wt = WatermarkCacheTarget.new
        wt.max_per_cache_server = 1
        wt.download_id = d.id
        wt.weight = 20
        wt.cache_type = "aac"
        wt.save
      end
    end
  end

  def self.down
  end
end
