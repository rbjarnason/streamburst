# Be sure to restart your webserver when you modify this file.

# Uncomment below to force Rails into production mode
# (Use only when you can't set environment variables through your web/app server)
# ENV['RAILS_ENV'] = 'development'
RAILS_GEM_VERSION = '2.2.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
#require_gem 'memcache-client'
#require_gem 'Ruby-MemCache'
require 'digest/sha1'
require 'memcache'
require 'taggable'

#require_gem 'acts_as_taggable'

Rails::Initializer.run do |config|
  # Skip frameworks you're not going to use
  # config.frameworks -= [ :action_web_service ]

  # Add additional load paths for your own custom dirs
  config.load_paths += %W( #{RAILS_ROOT}/app/cachers )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Only include the connection adapters you're actually going to use
  # config.connection_adapters = %w( mysql postgresql sqlite sqlserver db2 oci )

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake create_sessions_table')

  # BROKEN: Causes MySQL timeout errors on dev and production servers :BROKEN
  # config.action_controller.session_store = :active_record_store 
  config.action_controller.session = { 
	 :session_key => '_streamburst_session',
   :secret      => 'f1e376f47a74ec4339d60ce228ca2c9e9f960dd5ac65e4f4daf34d06778fc8db1daad446dfcdb1e59759bc8f071dc3347d079cc47555d4f00928e25566245da0'
   }	 

  config.action_mailer.default_charset = 'ISO-8859-1'
  config.action_mailer.default_arguments_charset = 'UTF-8'

  # Enable page/fragment caching by setting a file-based store
  # (remember to create the caching directory and make it readable to the application)
  # config.action_controller.fragment_cache_store = :file_store, "#{RAILS_ROOT}/cache"

  # config.active_record.observers = :page_title_cache

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc

  # See Rails::Configuration for more options
end

STREAMBURST_XML_API_VERSION = "0.9"

GBP_COUNTRIES = ["GB"]
EUR_COUNTRIES = ["AD", "CY", "MT", "MC", "ME", "SM", "SK", "VA", "AT", "BE", "FI", "FR", "DE", "GR", "IE", "IT", "LU", "NL", "PT", "ES", "SI"]

LONDON_SERVER_COUNTRIES = ["GB", "AT", "BE", "FI", "FR", "DE", "GR", "IE", "IT", "LU", "NL", "PT", "ES", "SI", "SE", "NO", "IS" ]
LA_SERVER_COUNTRIES = ["US", "CA"]

GBP_TO_USD_CONVERSION_RATE = 0.625860558
GBP_TO_EUR_CONVERSION_RATE = 0.860746026
GBP_TO_ISK_CONVERSION_RATE = 0.00344723995

USD_TO_GBP_CONVERSION_RATE = 0.625860558
USD_TO_EUR_CONVERSION_RATE = 0.727114084
USD_TO_ISK_CONVERSION_RATE = 0.005508

SPONSOR_BID_AFTER_HANDLING_FEE_RATIO = 1.0

#SCRIPT_LINES__ = {} if ENV['RAILS_ENV'] == 'development'
#ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS.update(:session_domain => ".streamburst.tv")

#TorrentUser.establish_connection "torrent_users_#{ENV["RAILS_ENV"]}"
#puts "torrent_users_#{ENV["RAILS_ENV"]}"
require File.dirname(__FILE__) + '/../vendor/plugins/trunk/lib/rails_file_column.rb'
require File.dirname(__FILE__) + '/../vendor/plugins/paypal_rvb/lib/payment_data.rb'
require File.dirname(__FILE__) + '/../vendor/plugins/g4r/lib/google4r/checkout.rb'

# Facebook hack to be able to store sessions correctly...
class CGI
  class Session
    class MemCacheStore
      def check_id(id) #:nodoc:#
        /[^0-9a-zA-Z\-\._]+/ =~ id.to_s ? false : true
      end
    end
  end
end

#class CGI
#  class Session
#    class MemCacheStore
#      def check_id(id)
#	      return true
#      end
#    end
#  end
#end
