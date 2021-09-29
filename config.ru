require 'sinatra'
require 'sinatra/contrib'
require 'sinatra/namespace'
require 'sinatra/json'
require 'sinatra/activerecord'
require './server'
run Sinatra::Application
