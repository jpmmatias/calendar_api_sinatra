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

  def user_allowed_to_see_event?(event, user_id)
    accepted_invites = Invite.where('event_id = ? and status = ?', event.id.to_s, '1')
    allowed = accepted_invites.map { |invite| invite.receiver_id }.unshift(event.owner_id).include?(user_id)

    halt response_body(403, { error: 'User not allowed' }) unless allowed
  end
end
