class VideoWatermark < ActiveRecord::Base
  after_create :generate_video_transaction_watermark

  def generate_video_transaction_watermark
    retrycount = 0
    begin
      self.watermark = rand(4294967294)
      self.save
    rescue
      if(retrycount < 10)
        retrycount+=1
        retry
      else
        logger.error("ERROR Could not save video watermark")
        admin_email = AdminMailer.create_critical_error("Video watermark couldn't be created", "no")
        AdminMailer.deliver(admin_email)
      end
    end
  end
end
