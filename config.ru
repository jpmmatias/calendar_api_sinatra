require 'sinatra'
require 'sinatra/contrib'
require 'sinatra/namespace'
require 'sinatra/json'
require 'sinatra/activerecord'
require './server'
require 'sidekiq'
require 'sidekiq/client'
require 'sidekiq/web'
require 'rack'

use Rack::Session::Pool
use Rack::Protection, except: :session_hijacking

run Rack::URLMap.new('/' => Sinatra::Application, '/sidekiq' => Sidekiq::Web)
