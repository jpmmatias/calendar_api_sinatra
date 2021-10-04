require './server'
require 'sidekiq'
require 'sidekiq/web'
require 'rack'

use Rack::Session::Pool
use Rack::Protection, except: :session_hijacking
sidekiq_config = { url: ENV['JOB_WORKER_URL'] }

Sidekiq.configure_server do |config|
  config.redis = sidekiq_config
end
Sidekiq.configure_client do |config|
  config.redis = sidekiq_config
end

run Rack::URLMap.new('/' => Sinatra::Application, '/sidekiq' => Sidekiq::Web)
