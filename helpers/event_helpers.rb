helpers do
  def create_events_csv(csv, user)
    results = create_event_and_invites_successed?(csv, user)
    return 201 unless results.include?(false)

    [400, { error: 'Error on users invitation, please try again' }.to_json]
  end

  def create_event_and_invites_successed?(csv, user)
    events = []
    csv.map do |event|
      new_event = create_event(event, user['id'])
      return halt response_body(400, { error: 'Error on creating events, please try again' }) unless new_event

      events.push(new_event.id)
      emails = get_emails_from_event(event, user['email'])
      invite_results = create_invites_and_return_success(emails, new_event.id, user['id'], events)
      !invite_results.include?(false)
    end
  end

  def create_event(event, user_id)
    new_event = Event.new(
      name: event['Nome de Evento'],
      local: event['Localidade'],
      description: event['Descrição'],
      start_date: DateTime.parse(event['Data e Hora Inicio']),
      end_date: DateTime.parse(event['Data e Hora Fim']),
      owner_id: user_id
    )

    new_event.save ? new_event : false
  end

  def get_emails_from_event(event, user_email)
    event['Participantes'].delete(' ').split(',').reject { |email| email == user_email }
  end

  def non_existing_event(event_id)
    Event.find(event_id).nil?
  end

  def email_and_id?(user_email, user_id)
    user_email && user_id
  end
end
