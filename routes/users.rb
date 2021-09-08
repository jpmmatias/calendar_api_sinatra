post '/v1/users/new_account' do
  body = get_body(request)
  new_user = User.new({
                        name: body['name'],
                        email: body['email'],
                        password: body['password']
                      })
  if new_user.save
    status 201
  else
    status 400
  end

rescue JSON::ParserError
  status 400
end

post '/v1/users/login' do
  body = get_body(request)
  user = User.find_by(email: body['email'])

  if body['email'].nil? || body['password'].nil?
    response_body(400, { error: 'Email or password cannot be blank. please try again' })
  end

  return response_body(400, { error: 'Wrong email please try again' }) if user.nil?

  return response_body(200, token(user)) if user&.authenticate(body['password'])

  response_body(400, { error: 'Wrong password, please try again' })

rescue JSON::ParserError
  status 400
end

private

def get_body(req)
  req.body.rewind
  JSON.parse(req.body.read)
end

def token(user)
  JWT.encode payload(user), ENV['JWT_SECRET'], 'HS256'
end

def payload(user)
  {
    exp: Time.now.to_i + 60 * 60,
    iat: Time.now.to_i,
    iss: ENV['JWT_ISSUER'],
    scopes: %w[events documents],
    user: { email: user.email, name: user.name, id: user.id }
  }
end

def response_body(status, body, include = nil)
  return [status(status), body.to_json] if include.nil?

  [status(status), body.as_json(include: include).to_json]
end
