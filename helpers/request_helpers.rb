helpers do
  def get_body(req)
    req.body.rewind
    JSON.parse(req.body.read)
  rescue JSON::ParserError
    halt response_body(400, error: 'Please send JSON for the API')
  end

  def response_body(status, body)
    [status(status), body.to_json]
  end

  def user
    @user ||= User.find(request.env[:user]['id'])
  end

  def event
    @event ||= Event.find_by(id: event_id)
  end

  def invite
    @invite ||= Invite.find_by(token: params['token'])
  end

  private

  def event_id
    params['event_id'].nil? ? params['id'] : params['event_id']
  end
end
