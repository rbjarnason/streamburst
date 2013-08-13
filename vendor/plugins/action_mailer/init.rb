#require 'tmail'
#begin
#  load(File.join(File.dirname(__FILE__), 'patch.rb'))
#  ActionController::Base.logger.fatal 'loaded patch for mail'
#rescue Exception => e
#  puts e.inspect
#  ActionController::Base.logger.fatal e if ActionController::Base.logger
#end