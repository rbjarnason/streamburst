namespace :system do
  desc "Send Full Order Status"
  task(:send_daily_order_status => :environment) do
    if ENV['distribution']
      if ENV['distribution'] == "weekly"
        email = SystemMailer.create_full_order_status("robert@streamburst.co.uk,ron@streamburst.co.uk,rob@streamburst.co.uk,dave@streamburst.co.uk", "Streamburst: Weekly Order Status Report")
        OrderMailer.deliver(email)      
      elsif ENV['distribution'] == "daily"
        email = SystemMailer.create_full_order_status("robert@streamburst.co.uk,dave@streamburst.co.uk", "Streamburst: Daily Order Status Report")
        OrderMailer.deliver(email)
      end
    else
      raise "usage: rake distribution= # distribtion e.g. daily or weekly"
    end
  end
end
