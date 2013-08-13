require 'digest/sha1'

class User < ActiveRecord::Base  
  has_and_belongs_to_many :roles
  has_many :line_items
  has_many :orders
  has_one :company

  validates_presence_of     :email, 
                            :password,
                            :first_name,
                            :last_name
  validates_uniqueness_of   :email
  validates_length_of       :password, 
                            :minimum => 6
  attr_accessor :password_confirmation
  
  before_save :add_customer_role
  
  def self.authenticate(email, password)
    user = self.find_by_email(email)
    if user and password
      expected_password = encrypted_password(password, user.salt)
      if user.hashed_password != expected_password
        user = nil
      end
    elsif user
      user = nil
    end
    user
  end

  # 'password' is a virtual attribute  
  def password
    @password
  end
  
  def password=(pwd)
    if pwd
      @password = pwd
      create_new_salt
      self.hashed_password = User.encrypted_password(self.password, self.salt)
    end
  end

  def safe_delete
    transaction do
      destroy
      if User.count.zero?
        raise "Can't delete last user"
      end
    end
  end  

  def has_role?(role_name)
    self.roles.detect{|role| role.name == role_name }
  end  
  
  def send_dvm_affiliate_welcome_mail
    begin
      welcome_email = UserMailer.create_welcome_to_dvm_program(self)
      welcome_email.set_content_type("text/html")
      UserMailer.deliver(welcome_email)
    rescue => ex
      logger.error(ex)
      logger.error(ex.backtrace)
      logger.error("Failed to send dvm signup welcome email for user: #{self.id} email: #{self.email}")
    end
  end

  def create_reset_code(host)
    self.reset_password_code_until = 1.day.from_now
    self.reset_password_code = File.read("/dev/urandom", 32).unpack("H*")[0]
    self.save(false)
    reset_password_email = UserMailer.create_reset_password(self,host)
    reset_password_email.set_content_type("text/html")
    UserMailer.deliver(reset_password_email)
  end
  
  def delete_reset_code
    self.reset_password_code_until = nil
    self.reset_password_code = nil
    self.save(false)
  end
  
  private

  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end

  def self.encrypted_password(password, salt)
    string_to_hash = password + "wibble" + salt
    Digest::SHA1.hexdigest(string_to_hash)
  end

  def add_customer_role
    unless self.has_role?("Customer")
      role = Role.find_by_name("Customer")
      self.roles << role
    end
  end
end
