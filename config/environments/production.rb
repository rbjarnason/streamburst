require 'syslog_logger'

# Variable that sets the ssl_protocol to http for development
SSL_PROTOCOL = "https://"
GEOIP_FILE = '/usr/local/share/GeoIP/GeoIP.dat'

# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

config.logger = SyslogLogger.new('content_store')
config.log_level = :info

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
#config.action_view.cache_template_loading            = true

ActionController::Base.session_options[:expires] = 21600

memcache_options = {
  :c_threshold => 10_000,
  :compression => false,
  :debug => false,
  :namespace => "app-#{RAILS_ENV}",
  :readonly => false,
  :urlencode => false
}
memcache_servers = ["92.48.80.4:11211"]

CACHE = MemCache.new(memcache_options)
CACHE.servers = memcache_servers
ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS.merge!({ 'cache' => CACHE })

config.cache_store = :mem_cache_store, '92.48.80.4:11211', { :namespace => "app-#{RAILS_ENV}-fragments" }
config.action_controller.session_store = :mem_cache_store 
  
# Old configs

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors if you bad email addresses should just be ignored
# config.action_mailer.raise_delivery_errors = false
