require 'csv'
get '/v1/events' do
  user = request.env[:user]

  events = Event.where(owner_id: user['id'])
  events = events.map { |event| EventSerializer.new(event).response }
  response_body(200, events)
end

get '/v1/events/:id' do
  user = request.env[:user]
  event = Event.where(['id = ? and owner_id = ?', params['id'].to_s, user['id'].to_s]).first
  return status 404 if event.nil?

  event = EventSerializer.new(event).response
  response_body(200, event)
end

post '/v1/events' do
  user = request.env[:user]

  unless params[:file].nil?
    csv = CSV.parse(params[:file][:tempfile].read.force_encoding('UTF-8'), headers: true)
    return create_events_csv(csv, user)
  end

  body = get_body(request)
  new_event = Event.new({
                          name: body['name'],
                          local: body['local'],
                          description: body['description'],
                          owner_id: user['id'],
                          start_date: body['start_date'],
                          end_date: body['end_date']
                        })
  if new_event.save
    event = EventSerializer.new(new_event).response
    response_body(201, event)
  else
    status 400
  end

rescue JSON::ParserError
  status 400
end

private

def get_body(req)
  req.body.rewind
  JSON.parse(req.body.read)
end

def response_body(status, body)
  [status(status), body.to_json]
end

def create_events_csv(csv, user)
  results = []
  events = []
  csv.map do |event|
    new_event = Event.new(
      name: event['Nome de Evento'],
      local: event['Localidade'],
      description: event['Descrição'],
      start_date: DateTime.parse(event['Data e Hora Inicio']),
      end_date: DateTime.parse(event['Data e Hora Fim']),
      owner_id: user['id']
    )

    return response_body(400, { error: 'Error on creating events, please try again' }) unless new_event.save

    events.push(new_event.id)
    emails = event['Participantes'].delete(' ').split(',')
    invite_results = emails.map do |email|
      reciver = User.find_by(email: email)

      invite = Invite.new({ event_id: new_event.id, sender_id: user['id'], receiver_id: reciver.id })

      if invite.event_day_already_passed?
        false
      else
        invite.save
      end
    rescue NoMethodError
      events.map { |id| Event.destroy(id) }
      return response_body(400, { error: 'User not found with this email' })
    end
    results.push(!invite_results.include?(false))
  end
  return 201 unless results.include?(false)

  response_body(400, error: 'Error on users invitation')
end
