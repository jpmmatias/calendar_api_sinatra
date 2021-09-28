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
    @app.call env
  rescue StandardError => e
    [status(e), { 'Content-Type' => 'application/json' }, [{ error: e }.to_json]]
  end

  def status(err)
    401 if err.message == nil_token_error
  end

  def nil_token_error
    @nil_token_error ||= 'Nil JSON web token'
  end

  def user_routes_in_path_info(env)
    ['/v1/users/login', '/v1/users/new_account'].include?(env['PATH_INFO'])
  end

  def fethc_http_auth(env)
    env.fetch('HTTP_AUTHORIZATION', '').slice(7..-1)
  end
end
