class InitialCategoriesData < ActiveRecord::Migration
  def self.up
    cat_episodes = Category.create :name => "Complete Episodes"
    cat_episodes.save

    cat_video_clips = Category.create :name => "Video Clips"
    cat_video_clips.save

    cat_ringtones = Category.create :name => "Mobile Ringtones"
    cat_ringtones.save

    cat_mp3 = Category.create :name => "MP3"
    cat_mp3.save    
  end

  def self.down
  end
end
