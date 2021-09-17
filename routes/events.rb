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
    events = CreateEvents.new(csv, user).call
    return response_body(201, events) if events.is_a?(Array)

    return response_body(400, { error: events })
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
