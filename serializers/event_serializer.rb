class EventSerializer
  def initialize(event)
    @event = event
  end

  def response
    { name: @event.name,
      local: @event.local,
      owner: @event.user,
      description: @event.description,
      start_date: @event.start_date,
      end_date: @event.end_date,
      documents: event_documents(@event.id),
      participants: event_participants(@event.id) }
  end

  def event_documents(event_id)
    Document.where(event_id: event_id)
  end

  def event_participants(event_id)
    accepted_invites = Invite.where('event_id = ? and status = ?', event_id.to_s, '1')
    accepted_invites.map { |invite| User.find(invite.reciver_id) }.unshift(@event.user)
  end
end
