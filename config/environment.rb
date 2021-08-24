ENV['SINATRA_ENV'] ||= 'development'
require 'rubygems'
require 'bundler'
require 'bundler/setup'
require 'rake'
require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'
require 'shrine'
require 'shrine/storage/file_system'

Bundler.require(:default, ENV['SINATRA_ENV'])

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: "db/#{ENV['SINATRA_ENV']}.sqlite3"
)

Shrine.storages = {
  cache: Shrine::Storage::FileSystem.new('public', prefix: 'uploads/cache'),
  store: Shrine::Storage::FileSystem.new('public', prefix: 'uploads')
}

Shrine.plugin :activerecord

require './server'
