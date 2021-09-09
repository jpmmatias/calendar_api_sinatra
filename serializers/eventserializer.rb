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
      documents: event_documents(@event.id) }
  end

  def event_documents(event_id)
    Document.where(event_id: event_id)
  end
end
