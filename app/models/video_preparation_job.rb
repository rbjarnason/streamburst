class VideoPreparationJob < ActiveRecord::Base
  has_and_belongs_to_many :video_preparation_queues
  after_create :generate_job_key
  belongs_to :order
  belongs_to :product

  # Preparation Timing Types
  PREPARATION_START_TIMING = 0
  NO_WATERMARK_TIMING = 1
  NO_WATERMARK_TIMING_NO_INTRO = 2
  CACHED_AUDIO_WATERMARK_TIMING = 3
  CACHED_AUDIO_WATERMARK_TIMING_NO_INTRO = 4
  AUDIO_WATERMARK_TIMING = 5
  AUDIO_WATERMARK_TIMING_NO_INTRO = 6
  MP3_AUDIO_WATERMARK_TIMING = 7
  WAV_AUDIO_WATERMARK_TIMING = 8

  # Number of Timing Median Values per Type
  MAX_TIMING_MEDIAN_VALUES = 5

  def deactivate
    self.active = 0
    self.save
    self.remove_from_video_preparation_queue
    self.remove_from_wait_queue
  end

  def add_to_video_preparation_queue
    logger.info("Job #{self.job_key} added to queue at: #{Time.now.to_i}")
    queue = VideoPreparationQueue.find_by_name("main")
    current_job = queue.video_preparation_jobs.find_by_user_id(self.user_id) #  :lock => true)
    wait_queue = VideoPreparationQueue.find_by_name("wait")
    if current_job
      logger.info("Found current job - adding to wait queue")
      wait_queue = VideoPreparationQueue.find_by_name("wait")
      self.added_to_queue_time = Time.now.to_i
      self.save
      wait_queue.video_preparation_jobs << self
    else
      self.added_to_queue_time = Time.now.to_i
      self.save
      queue.video_preparation_jobs << self
      logger.info("Added to queue at: #{self.added_to_queue_time}")
    end
  end

  def add_timing(type, time, video_server_id, per_mb = true)
    time = time.to_f / (per_mb == true ? self.file_size_mb.to_f : 1.0)
    begin
      preparation_time = VideoPreparationTime.new
      preparation_time.video_server_id = video_server_id
      preparation_time.activity_type = type
      preparation_time.time = time
      preparation_time.save
      count_by_type = VideoPreparationTime.count("activity_type = #{type} AND video_server_id = #{video_server_id}")
      logger.info("Added time: #{time} type: #{type} video_server_id: #{video_server_id} Count_by_type: #{count_by_type}")
      if count_by_type > MAX_TIMING_MEDIAN_VALUES
        VideoPreparationTime.find(:first, :conditions => "activity_type = #{type} AND video_server_id = #{video_server_id}", 
                                  :order => "created_at ASC").destroy
      end
    rescue => ex
      logger.error("Couldn't add timing")
      logger.error(ex)
      logger.error(ex.backtrace)
    end
  end

  def get_timing(type, video_server_id, per_mb = true)
    begin
      times = VideoPreparationTime.find(:all, :conditions => "activity_type = #{type} AND video_server_id = #{video_server_id}", 
                                  :order => "time DESC", :limit => MAX_TIMING_MEDIAN_VALUES)
      if times.length > 0
        # Return median time
        median_time = times[times.length/2].time
        logger.info("Get timing - Median time: #{median_time}")
        return median_time * (per_mb == true ? self.file_size_mb.to_f : 1.0)
      end
    rescue => ex
      logger.error("Couldn't get timing")
      logger.error(ex)
      logger.error(ex.backtrace)
    end

    default_time = 0.0
    case type
    when PREPARATION_START_TIMING
      default_time = 1.0
    when NO_WATERMARK_TIMING
      default_time = 0.1
    when NO_WATERMARK_TIMING_NO_INTRO
      default_time = 0.09
    when CACHED_AUDIO_WATERMARK_TIMING
      default_time = 0.14
    when CACHED_AUDIO_WATERMARK_TIMING_NO_INTRO
      default_time = 0.11
    when AUDIO_WATERMARK_TIMING
      default_time = 0.22
    when AUDIO_WATERMARK_TIMING_NO_INTRO
      default_time = 0.21
    when MP3_AUDIO_WATERMARK_TIMING
      default_time = 0.25
    when WAV_AUDIO_WATERMARK_TIMING
      default_time = 0.35
    end
    logger.info("Get timing - Default time: #{default_time}")
    
    return default_time * (per_mb == true ? self.file_size_mb.to_f : 1.0)
  end

  def preparation_started(video_server_id)
    self.in_progress = true
    self.start_processing_time = Time.now.to_i
    self.video_server_id = video_server_id
    self.save
    add_timing(PREPARATION_START_TIMING, self.start_processing_time-self.added_to_queue_time, 0, false)
    logger.info("Job started at: #{self.start_processing_time}")
  end

  def setup_timings
    perparation_wait_time = get_timing(PREPARATION_START_TIMING, 0, false) + get_timing(self.activity_timing_type, 1)
    @wait_jobs = VideoPreparationQueue.find_by_name("wait").video_preparation_jobs.find_all_by_user_id(self.user_id, :order => "video_preparation_jobs.created_at ASC")
    wait_pos = 0
    wait_pos_counter = 0
    for wait_job in @wait_jobs
      wait_pos_counter += 1
      if wait_job.id == self.id
        wait_pos = wait_pos_counter
      end
    end
    if wait_pos > 0
      perparation_wait_time *= (wait_pos + 1)
    end
    logger.info("Setup timings: prep_wait_time #{perparation_wait_time} wait_pos: #{wait_pos}")
    perparation_wait_time = 10 if perparation_wait_time <= 10
    return (self.estimated_preparation_time = perparation_wait_time).to_i
  end

  def setup_status_text
    @wait_jobs = VideoPreparationQueue.find_by_name("wait").video_preparation_jobs.find_all_by_user_id(self.user_id, :order => "video_preparation_jobs.created_at ASC")
    if @wait_jobs.length > 0
      status_text = I18n.translate :other_jobs_in_preperation
    else
     status_text = I18n.translate :job_in_queue
    end
    return self.status_text = status_text
  end

  def remove_from_video_preparation_queue
    queue = VideoPreparationQueue.find_by_name("main")
    queue.video_preparation_jobs.delete(self)
    logger.info("Job #{self.job_key} removed from queue at: #{Time.now.to_i}")
    if self.success and self.file_size_mb > 100 and not self.no_work_done and not self.cancelled and self.active
      begin
        logger.info("I was added at: #{self.added_to_queue_time}")
        total_queue_time = Time.now.to_i - self.added_to_queue_time
        logger.info("Total Queue Time: #{total_queue_time}")
        add_timing(self.activity_timing_type, total_queue_time, self.video_server_id)
        queue.save
      rescue
        logger.error("Couldn't update preparation time!")
      end
    else
      logger.info("Not adding timing for self.success #{self.success} and self.file_size_mb #{self.file_size_mb} and not self.no_work_done #{self.no_work_done} and not self.cancelled #{self.cancelled} and self.active #{self.active}")
    end
    wait_queue = VideoPreparationQueue.find_by_name("wait")
    wait_jobs = wait_queue.video_preparation_jobs.find_all_by_user_id(self.user_id, :limit => 1, :order => "video_preparation_jobs.created_at ASC") # :lock => true)
    if wait_jobs.length > 0
      logger.info("Set next wait job as active #{self.job_key}")
      wait_queue.video_preparation_jobs.delete(wait_jobs[0])
      wait_jobs[0].add_to_video_preparation_queue
      queue.video_preparation_jobs.delete(self)
    end
  end
  
  def remove_from_wait_queue
    wait_queue = VideoPreparationQueue.find_by_name("wait")
    my_wait_job = wait_queue.video_preparation_jobs.find_by_job_key(self.job_key)
    if my_wait_job
      wait_queue.video_preparation_jobs.delete(self)
    end
  end

private

  def random_md5_sum
    md5 = Digest::MD5::new
    now = Time::now
    md5.update(now.to_s)
    md5.update(String(now.usec))
    md5.update(String(rand(0)))
    md5.update(String($$))
    md5.update("robobor")
    md5.hexdigest
  end

  def generate_job_key
    retrycount = 0
    begin
      self.job_key = random_md5_sum.to_s
      self.save
    rescue
      if(retrycount < 10)
        retrycount+=1
        retry
      else
        logger.error("ERROR Could not save job")
        admin_email = AdminMailer.create_critical_error("Job key couldn't be created", "no")
        AdminMailer.deliver(admin_email)
      end
    end
  end
end
