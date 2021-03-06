require './config/environment'
require_relative './lib/middlewares/init'

configure do
  enable :cross_origin
  set :public_folder, (proc { File.join(root, '../public') })
  set :static, true
  set :database_file, File.expand_path('config/database.yml', __dir__)
  set :default_content_type, 'application/json'
  set :allow_origin, '*'
  set :allow_methods, %i[get post patch put delete options]
  set :allow_credentials, true
  set :max_age, 1_728_000
  set :expose_headers, ['Content-Type']
end

options '*' do
  response.headers['Allow'] = 'HEAD,GET,POST,DELETE,OPTIONS'
  response.headers['Access-Control-Allow-Headers'] =
    'X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept'
  200
end

require_relative 'lib/helpers/init'
require_relative 'lib/models/init'
require_relative 'lib/serializers/init'
require_relative 'lib/services/init'
require_relative 'lib/routes/init'
