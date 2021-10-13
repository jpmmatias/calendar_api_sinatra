require 'sinatra'
require 'sinatra/contrib'
require 'sinatra/namespace'
require 'sinatra/json'
require 'sinatra/activerecord'
require './server'
require 'sidekiq'
require 'sidekiq/client'

run Rack::URLMap.new('/' => Sinatra::Application)
