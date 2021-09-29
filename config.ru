require './server'
run Sinatra::Application
Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://localhost:6379' }
end

run Rack::URLMap.new('/' => App, '/sidekiq' => Sidekiq::Web)
