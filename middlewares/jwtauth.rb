class JwtAuth
  def initialize(app)
    @app = app
  end

  def call(env)
    return @app.call env if user_routes_in_path_info(env)

    options = { algorithm: 'HS256', iss: ENV['JWT_ISSUER'] }
    bearer = env.fetch('HTTP_AUTHORIZATION', '').slice(7..-1)
    payload, header = JWT.decode bearer, ENV['JWT_SECRET'], false

    env[:scopes] = payload['scopes']
    env[:user] = payload['user']

    @app.call env
  rescue JWT::DecodeError
    [401, { 'Content-Type' => 'text/plain' }, ['A token must be passed.']]
  rescue JWT::ExpiredSignature
    [403, { 'Content-Type' => 'text/plain' }, ['The token has expired.']]
  rescue JWT::InvalidIssuerError
    [403, { 'Content-Type' => 'text/plain' }, ['The token does not have a valid issuer.']]
  rescue JWT::InvalidIatError
    [403, { 'Content-Type' => 'text/plain' }, ['The token does not have a valid "issued at" time.']]
  end

  def user_routes_in_path_info(env)
    ['/v1/users/login', '/v1/users/new_account'].include?(env['PATH_INFO'])
  end
end
