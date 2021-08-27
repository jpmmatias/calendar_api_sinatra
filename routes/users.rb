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
    { success: true, message: 'User logged successfully' }.to_json
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
