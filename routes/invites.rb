get '/v1/invites' do
  user = request.env[:user]
  invites = InviteHelper.available_invites_from_user(user['id'])
  response_body(200, invites)
end

post '/v1/events/:event_id/invite' do
  user = request.env[:user]
  body = get_body(request)

  return response_body(400, error: 'Non existing event') if non_existing_event(params['event_id'])

  if email_and_id?(body['user_email'], body['user_id'])
    return response_body(400,
                         { error: 'Send email or the ID from the user, but not both' })
  end

  if multiple_emails?(body['users_emails'])
    return status 201 if InviteHelper.invitation_successed?(params['event_id'], body['users_emails'],
                                                            user['id'])

    status 400
  end

  receiver = get_receiver(body['user_email'], body['user_id'])

  return response_body(400, { error: 'User already invited' }) if InviteHelper.invite_already_made?(receiver,
                                                                                                    params['event_id'])

  invite = Invite.new({ event_id: params['event_id'], sender_id: user['id'], receiver_id: receiver.id })

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

def non_existing_event(event_id)
  Event.find(event_id).nil?
end

def email_and_id?(user_email, user_id)
  user_email && user_id
end

def get_receiver(user_email, user_id)
  user_id ? User.find(user_id) : User.find_by(email: user_email)
end

def multiple_emails?(emails)
  emails ? true : false
end
