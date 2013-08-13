class VideoPreparationQueue < ActiveRecord::Base
  has_and_belongs_to_many :video_preparation_jobs, 
                          :order => "video_preparation_jobs.created_at DESC" do
    def find_highest_priority
      find :first, :conditions => "video_preparation_jobs.active = 1 AND video_preparation_jobs.in_progress = 0", :lock => true
    end
  end
end
