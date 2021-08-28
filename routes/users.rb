post '/v1/users/new_account' do
  body = get_body(request)
  new_user = User.new({
                        name: body['name'],
                        email: body['email'],
                        password: body['password']
                      })
  if new_user.save
    status 201
    { success: true, message: 'User created successfully' }.to_json
  else
    status 400
    { success: false }.to_json
  end

rescue JSON::ParserError
  status 400
  { success: false }.to_json
end

post '/v1/users/login' do
  body = get_body(request)
  user = User.find_by(email: body['email'])

  if user&.authenticate(body['password'])
    status 200
    { token: token(user) }.to_json
  else
    status 400
    { success: false }.to_json
  end

rescue JSON::ParserError
  status 400
  { success: false }.to_json
end

private

def get_body(req)
  req.body.rewind
  JSON.parse(req.body.read)
end

def token(user)
  JWT.encode payload(user), ENV['JWT_SECRET'], 'HS256'
end

def payload(username)
  {
    exp: Time.now.to_i + 60 * 60,
    iat: Time.now.to_i,
    iss: ENV['JWT_ISSUER'],
    scopes: %w[documents events],
    user: {
      username: username
    }
  }
end
