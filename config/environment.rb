ENV['SINATRA_ENV'] ||= 'development'
require 'rubygems'
require 'bundler'
require 'bundler/setup'
require 'rake'
require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'

Bundler.require(:default, ENV['SINATRA_ENV'])

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: "db/#{ENV['SINATRA_ENV']}.sqlite3"
)


require './server'
