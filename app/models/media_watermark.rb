class MediaWatermark < ActiveRecord::Base
  belongs_to :download
  belongs_to :user
  belongs_to :line_item

  after_create :generate_audio_transaction_watermark
  
  def generate_audio_transaction_watermark
    retrycount = 0
    begin
      self.watermark = rand(4294967294)
      self.save
    rescue
      if(retrycount < 10)
        retrycount+=1
        retry
      else
        logger.error("ERROR Could not save watermark")
        admin_email = AdminMailer.create_critical_error("Watermark couldn't be created", "no")
        AdminMailer.deliver(admin_email)
      end
    end
  end
end
