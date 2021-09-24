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

  def user_allowed_to_see_event?
    user_id = request.env[:user]['id']
    event_exists?
    allowed = accepted_invites.map(&:receiver_id).unshift(event.owner_id).include?(user_id)

    halt response_body(403, { error: 'User not allowed' }) unless allowed
    true
  end

  def user_allowed_to_see_invite?
    user_id = request.env[:user]['id']
    allowed = user_id == invite.sender_id || user_id == invite.receiver_id

    halt response_body(403, { error: 'User not allowed' }) unless allowed
    true
  end

  def user_owner_of_the_event?
    halt response_body(403, { error: 'User not allowed' }) unless event.owner_id == request.env[:user]['id']
    true
  end

  def user
    @user ||= User.find(request.env[:user]['id'])
  end

  def event_exists?
    halt response_body(404, { error: 'Event not found' }) if event.nil?
    true
  end

  def invite_exists?
    halt response_body(404, { error: 'Invite not found' }) if invite.nil?
    true
  end

  def event
    @event ||= Event.find_by(id: event_id)
  end

  private

  def invite
    @invite ||= Invite.find_by(token: params['token'])
  end

  def event_id
    params['event_id'].nil? ? params['id'] : params['event_id']
  end

  def accepted_invites
    Invite.where('event_id = ? and status = ?', @event.id.to_s, '1')
  end

  def filtred_events?
    params['start_date'] || params['end_date'] ? true : false
  end

  def error_on_filtering?(filter_result)
    halt response_body(400, { error: filter_result }) if filter_result.is_a? String
    false
  end
end
