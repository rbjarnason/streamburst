class UserMailer < ActionMailer::Base
  def welcome_to_dvm_program(user)
    @subject       = "Welcome to the Streamburst DVM Affiliate Program"
    @recipients    = user.email
    @from          = 'support@streamburst.tv'
    @body["user"] = user
    @sent_on    = Time.now
  end

  def reset_password(user, host)
    @subject       = "#{I18n.translate(:Password_Reset_Information)}"
    @recipients    = user.email
    @from          = 'support@streamburst.tv'
    @body["user"] = user
    @body[:url]  = "https://#{host}/users/reset/#{user.reset_password_code}"
    @sent_on    = Time.now
  end
end
