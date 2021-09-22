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

  def update_values(body)
    body.map { |key, value| { key.gsub(' 00:00:00+00', '') => value } }.reduce(:merge)
  end

  def user_allowed_to_see_event?
    user_id = request.env[:user]['id']
    event_exists?(event)
    allowed = accepted_invites.map(&:receiver_id).unshift(event.owner_id).include?(user_id)

    halt response_body(403, { error: 'User not allowed' }) unless allowed
  end

  def user
    @user ||= User.find(request.env[:user]['id'])
  end

  def event_exists?(event)
    halt response_body(404, { error: 'Event not found' }) if event.nil?
  end

  private

  def event
    @event ||= Event.find_by(id: event_id)
  end

  def event_id
    params['event_id'].nil? ? params['id'] : params['event_id']
  end

  def accepted_invites
    Invite.where('event_id = ? and status = ?', @event.id.to_s, '1')
  end
end
