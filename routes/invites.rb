get '/v1/invites' do
  user = request.env[:user]
  invites = Invite.where('reciver_id = ? and status = ?', user['id'].to_s, '0')
  invites = invites.map { |invite| invite.response_json }

  { success: true, invites: invites }.to_json
end

post '/v1/events/:event_id/invite' do
  user = request.env[:user]
  body = get_body(request)
  reciver = User.find_by(email: body['reciver_email'])

  invite = Invite.new({ event_id: params['event_id'], sender_id: user['id'], reciver_id: reciver.id })

  if invite.save
    status 201
    { success: true, invite: invite.response_json }.to_json
  else
    status 401
    { success: false, message: 'Error on creating invite' }
  end
end

put '/v1/invites/:id/accept' do
  invite = Invite.find(params[:id])
  invite.status = 1
  if invite.save
    status 200
    { success: true,
      message: 'Invitation was successfully accepted' }.to_json
  end
end

put '/v1/invites/:id/refuse' do
  invite = Invite.find(params[:id])
  invite.status = 2
  if invite.save
    status 200
    { success: true,
      message: 'Invitation was successfully refused' }.to_json
  end
end

put '/v1/invites/:id/perhaps' do
  invite = Invite.find(params[:id])
  invite.status = 3
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
