get '/v1/events' do
  events = Event.all
  if events.empty?
    status 204
    { success: true, message: 'No events created yet' }.to_json
  else
    { success: true, events: events.as_json(include: [:documents]) }.to_json
  end
end

get '/v1/events/:id' do
  event = Event.where(id: params['id']).first
  status 404 if event.nil?
  { success: true, event: event.as_json(include: [:documents]) }.to_json
end

post '/v1/events' do
  body = get_body(request)
  new_event = Event.new({
                          name: body['name'],
                          local: body['local'],
                          description: body['description'],
                          owner: body['owner'],
                          start_date: body['start_date'],
                          end_date: body['end_date']
                        })
  if new_event.save

    status 201
    { success: true, event: new_event.to_json }.to_json
  else
    status 400
    { success: false }.to_json
  end

rescue JSON::ParserError
  status 400
  { success: false }.to_json
end

private

def get_body(req)
  req.body.rewind
  JSON.parse(req.body.read)
end
