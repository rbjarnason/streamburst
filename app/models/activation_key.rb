class ActivationKey < ActiveRecord::Base
  validates_uniqueness_of   :activation_key
  before_create :generate_activation_key

  def generate_activation_key
    md5 = Digest::MD5::new
    now = Time::now
    md5.update(now.to_s)
    md5.update(String(now.usec))
    md5.update(String(rand(0)))
    md5.update(String($$))
    md5.update("ro2bor")
    self.activation_key = MD5.hexdigest
  end  

end
