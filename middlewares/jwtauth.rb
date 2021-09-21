class JwtAuth
  def initialize(app)
    @app = app
  end

  def call(env)
    return @app.call env if user_routes_in_path_info(env)

    bearer = fethc_http_auth(env)
    payload, header = JWT.decode bearer, ENV['JWT_SECRET'], false

    env[:scopes] = payload['scopes']
    env[:user] = payload['user']
    env[:alg] = header['alg']
    rescue_jwt
    @app.call env
  end

  def user_routes_in_path_info(env)
    ['/v1/users/login', '/v1/users/new_account'].include?(env['PATH_INFO'])
  end

  def fethc_http_auth(env)
    env.fetch('HTTP_AUTHORIZATION', '').slice(7..-1)
  end

  def rescue_jwt
  rescue JWT::DecodeError
    [401, { 'Content-Type' => 'application/json' }, [{ error: 'A token must be passed.' }.to_json]]
  rescue JWT::ExpiredSignature
    [403, { 'Content-Type' => 'application/json' }, [{ errror: 'The token has expired.' }.to_json]]
  rescue JWT::InvalidIssuerError
    [403, { 'Content-Type' => 'application/json' }, [{ error: 'The token does not have a valid issuer.' }.to_json]]
  rescue JWT::InvalidIatError
    [403, { 'Content-Type' => 'application/json' },
     [{ error: 'The token does not have a valid "issued at" time.' }.to_json]]
  end
end
