get '/v1/invites' do
  user = request.env[:user]
  invites = Invite.where('reciver_id = ? and status = ?', user['id'].to_s, '0')
  invites = invites.map { |invite| invite.response_json }

  { success: true, invites: invites }.to_json
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
    unless results.include?(false)
      status 201
      return { success: true, message: 'Users were successfully invited' }.to_json
    end
  end

  reciver = body['user_email'].nil? ? User.find(body['user_id']) : User.find_by(email: body['user_email'])

  invite = Invite.new({ event_id: params['event_id'], sender_id: user['id'], reciver_id: reciver.id })

  if invite.event.start_date < DateTime.now
    status 400
    return { success: false, message: "Can't create invite because the day of the event already passed" }.to_json
  end

  if invite.save
    status 201
    { success: true, invite: invite.response_json }.to_json
  else
    status 401
    { success: false, message: 'Error on creating invite' }
  end
rescue JSON::ParserError
  status 400
  { success: false, message: 'Please send JSON for the API' }.to_json
end

put '/v1/invites/:id/accept' do
  invite = Invite.find(params[:id])
  if invite.event.start_date < DateTime.now
    status 400
    return { success: false, message: "Can't accept invite because the day of the event already passed" }.to_json
  else
    invite.status = 1
  end
  if invite.save
    status 200
    { success: true,
      message: 'Invitation was successfully accepted' }.to_json
  end
end

put '/v1/invites/:id/refuse' do
  invite = Invite.find(params[:id])
  if invite.event.start_date < DateTime.now
    status 400
    return { success: false, message: "Can't refuse invite because the day of the event already passed" }.to_json
  else
    invite.status = 2
  end
  if invite.save
    status 200
    { success: true,
      message: 'Invitation was successfully refused' }.to_json
  end
end

put '/v1/invites/:id/perhaps' do
  invite = Invite.find(params[:id])
  if invite.event.start_date < DateTime.now
    status 400
    return { success: false,
             message: "Can't change invite status to perhaps because the day of the event already passed" }.to_json
  else
    invite.status = 3
  end
  if invite.save
    status 200
    { success: true,
      message: 'Invitation status was successfully changed to perhaps' }.to_json
  end
end

private

def get_body(req)
  req.body.rewind
  JSON.parse(req.body.read)
end
