get '/v1/invites' do
  user = request.env[:user]
  invites = Invite.where('reciver_id = ? and status = ?', user['id'].to_s, '0')
  invites = invites.map { |invite| InviteSerializer.new(invite).response }

  response_body(200, invites)
end

post '/v1/events/:event_id/invite' do
  user = request.env[:user]
  body = get_body(request)

  if body['users_emails']
    emails = body['users_emails']
    results = emails.map do |email|
      reciver = User.find_by(email: email)
      invite = Invite.new({ event_id: params['event_id'], sender_id: user['id'], reciver_id: reciver.id })
      invite.save
    end
    return status 201 unless results.include?(false)
  end

  reciver = body['user_email'].nil? ? User.find(body['user_id']) : User.find_by(email: body['user_email'])

  invite = Invite.new({ event_id: params['event_id'], sender_id: user['id'], reciver_id: reciver.id })

  return status 400 if invite.event_day_already_passed?

  if invite.save
    response_body(201, InviteSerializer.new(invite).response)
  else
    response_body(401, { error: 'Error on creating invite' })
  end
rescue JSON::ParserError
  response_body(400, { error: 'Please send JSON for the API' })
end

put '/v1/invites/:id/accept' do
  invite = Invite.find(params[:id])

  return status 400 if invite.event_day_already_passed?

  invite.status = 1

  return status 200 if invite.save
end

put '/v1/invites/:id/refuse' do
  invite = Invite.find(params[:id])

  return status 400 if invite.event_day_already_passed?

  invite.status = 2

  status 200 if invite.save
end

put '/v1/invites/:id/perhaps' do
  invite = Invite.find(params[:id])

  return status 400 if invite.event_day_already_passed?

  invite.status = 3

  status 200 if invite.save
end

private

def get_body(req)
  req.body.rewind
  JSON.parse(req.body.read)
end

def response_body(status, body)
  [status(status), body.to_json]
end
