source 'https://rubygems.org'

gem 'activerecord', '~> 6.0', '>= 6.0.3.2', require: 'active_record'
gem 'bcrypt'
gem 'falcon'
gem 'puma'
gem 'rack-contrib'
gem 'rake'
gem 'shrine', '~> 3.0'
gem 'sinatra'
gem 'sinatra-activerecord', require: 'sinatra/activerecord'
gem 'sinatra-contrib', require: false
gem 'sinatra-cross_origin'
gem 'thin'
gem 'webrick'

group :development do
  gem 'pry'
  gem 'rubocop'
  gem 'tux'
end

group :test do
  gem 'database_cleaner', git: 'https://github.com/bmabey/database_cleaner.git'
  gem 'factory_bot'
  gem 'rack-test'
  gem 'rspec'
  gem 'shoulda-matchers', '~> 5.0'
  gem 'simplecov', require: false
end

group :development, :test do
  gem 'rerun'
  gem 'sqlite3'
end
