require 'rubygems'
require 'daemons'
require 'yaml'

f = File.open( File.dirname(__FILE__) + '/config/worker.yml')
worker_config = YAML.load(f)

ENV['RAILS_ENV'] = worker_config['rails_env']

options = {
    :app_name   => "watermark_worker_"+ENV['RAILS_ENV'],
    :dir_mode   => :system,
    :backtrace  => true,
    :monitor    => true,
    :log_output => true,
    :script     => ENV['RAILS_ENV'] == "development" ? "/home/robert/work/ContentStoreDevelopment/lib/watermark_cache_worker/watermark_worker_daemon.rb" : "/home/robert/work/ContentStoreProductionV2/lib/watermark_cache_worker/watermark_worker_daemon.rb" 
  }

Daemons.run(File.join(File.dirname(__FILE__), 'watermark_worker_daemon.rb'), options)
