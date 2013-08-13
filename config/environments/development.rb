# Variable that sets the ssl_protocol to http for development
SSL_PROTOCOL = "http://"
GEOIP_FILE = 'lib/GeoIP.dat'

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes     = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils        = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

ActionController::Base.session_options[:expires] = 21600

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = true

memcache_options = {
  :c_threshold => 10_000,
  :compression => false,
  :debug => false,
  :namespace => "app-#{RAILS_ENV}",
  :readonly => false,
  :urlencode => false
}
memcache_servers = ["localhost:11211"]

CACHE = MemCache.new(memcache_options)
CACHE.servers = memcache_servers
ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS.merge!({ 'cache' => CACHE })

#config.cache_store = :mem_cache_store, "localhost:11211", { :namespace => "app-#{RAILS_ENV}-fragments" }
config.action_controller.session_store = :mem_cache_store 


