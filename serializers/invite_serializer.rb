class InviteSerializer
  def initialize(invite)
    @token = invite.token
    @sender_id = invite.sender_id
    @event = invite_event(invite.event_id)
  end

  def response
    {
      token: @token,
      event_name: @event.name,
      sender_name: invite_sender(@sender_id),
      event_start_date: @event.start_date.to_s,
      event_end_date: @event.end_date.to_s
    }
  end

  def invite_event(event_id)
    Event.find(event_id)
  end

  def invite_sender(sender_id)
    User.find(sender_id).name
  end
end
