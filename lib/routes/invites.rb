get '/v1/invites' do
  invites = available_invites_from_user(user['id'])
  response_body(200, invites)
end

get '/v1/invites/:token' do
  serialized_invite = InviteSerializer.new(invite).response
  response_body(200, serialized_invite)
end

post '/v1/events/:event_id/invite' do
  body = get_body(request)

  invites = CreateInvites.new(params, body, user).call

  return response_body(201, invites) if invites.is_a?(Array)

  error = invites

  response_body(400, { error: error })
end

put '/v1/invites/:token/accept' do
  return response_body(400, { error: 'Event day already passed' }) if invite.event_day_already_passed?

  invite.status = 1

  return status 200 if invite.save
end

put '/v1/invites/:token/refuse' do
  return response_body(400, { error: 'Event day already passed' }) if invite.event_day_already_passed?

  invite.status = 2

  status 200 if invite.save
end

put '/v1/invites/:token/perhaps' do
  return response_body(400, { error: 'Event day already passed' }) if invite.event_day_already_passed?

  invite.status = 3

  status 200 if invite.save
end

delete '/v1/invites/:token' do
  invite.destroy
  status 204
end

private

def available_invites_from_user(id)
  invites = Invite.where('receiver_id= ? and status = ?', id.to_s, '0')
  invites.map { |invite| InviteSerializer.new(invite).response }
end
