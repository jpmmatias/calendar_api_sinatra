class InviteSerializer
  def initialize(invite)
    @invite = invite
    @event = invite_event(invite.event_id)
  end

  def response
    { event_name: @event.name, sender_name: invite_sender(@invite.sender_id).name, event_start_date: @event.start_date.to_s,
      event_end_date: @event.end_date.to_s }
  end

  def invite_event(event_id)
    Event.find(event_id)
  end

  def invite_sender(sender_id)
    User.find(sender_id)
  end
end
