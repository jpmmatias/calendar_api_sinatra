ENV['SINATRA_ENV'] ||= 'development'
require 'dotenv/load'
require 'rubygems'
require 'bundler'
require 'bundler/setup'
require 'rake'
require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'

db_config = YAML.load_file('config/database.yml')
ActiveRecord::Base.establish_connection(db_config[ENV['SINATRA_ENV']])

Bundler.require(:default, ENV['SINATRA_ENV'])

require './server'
