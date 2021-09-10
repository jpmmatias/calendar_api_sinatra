get '/v1/invites' do
  user = request.env[:user]
  invites = Invite.where('reciver_id = ? and status = ?', user['id'].to_s, '0')
  invites = invites.map { |invite| InviteSerializer.new(invite).response }

  response_body(200, invites)
end

post '/v1/events/:event_id/invite' do
  return response_body(400, error: 'Non existing event') if non_existing_event(params['event_id'])

  user = request.env[:user]
  body = get_body(request)

  if body['user_email'] && body['user_id']
    return response_body(400,
                         { error: 'Send email or the ID from the user, but not both' })
  end

  if body['users_emails']
    emails = body['users_emails']
    results = create_invites_and_return_success(emails, params['event_id'])
    return status 201 unless results.include?(false)

    return status 400
  end

  reciver = body['user_email'].nil? ? User.find(body['user_id']) : User.find_by(email: body['user_email'])

  return response_body(400, { error: 'User already invited' }) if invite_already_made(reciver, params['event_id'])

  invite = Invite.new({ event_id: params['event_id'], sender_id: user['id'], reciver_id: reciver.id })

  return status 400 if invite.event_day_already_passed?

  if invite.save
    response_body(201, InviteSerializer.new(invite).response)
  else
    response_body(401, { error: 'Error on creating invite' })
  end

rescue ActiveRecord::RecordNotFound
  response_body(400, { error: 'User not found with this ID' })
rescue NoMethodError
  response_body(400, { error: 'User not found with this email' })
rescue JSON::ParserError
  response_body(400, { error: 'Please send JSON for the API' })
end

put '/v1/invites/:id/accept' do
  invite = Invite.find(params[:id])

  return response_body(400, { error: 'Event day already passed' }) if invite.event_day_already_passed?

  invite.status = 1

  return status 200 if invite.save
end

put '/v1/invites/:id/refuse' do
  invite = Invite.find(params[:id])

  return response_body(400, { error: 'Event day already passed' }) if invite.event_day_already_passed?

  invite.status = 2

  status 200 if invite.save
end

put '/v1/invites/:id/perhaps' do
  invite = Invite.find(params[:id])

  return response_body(400, { error: 'Event day already passed' }) if invite.event_day_already_passed?

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

def invite_already_made(reciver, event_id)
  !Invite.where('reciver_id = ? and event_id = ?',
                reciver.id.to_s,
                event_id.to_s).empty?
end

def non_existing_event(event_id)
  Event.find(event_id).nil?
end

def create_invites_and_return_success(emails, event_id)
  emails.map do |email|
    reciver = User.find_by(email: email)
    invite = Invite.new({ event_id: event_id, sender_id: request.env[:user]['id'], reciver_id: reciver.id })

    if invite.event_day_already_passed?
      false
    else
      invite.save
    end
  end
end
