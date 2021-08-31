get '/v1/events' do
  events = Event.all
  if events.empty?
    status 200
    { success: true, events: [] }.to_json
  else
    events = events.map { |event| event.response_json }
    { success: true, events: events }.to_json
  end
end

get '/v1/events/:id' do
  event = Event.where(id: params['id']).first
  # binding.pry
  if event.nil?
    status 404
  else
    status 200
    { success: true, event: event.response_json }.to_json
  end
end

post '/v1/events' do
  body = get_body(request)
  new_event = Event.new({
                          name: body['name'],
                          local: body['local'],
                          description: body['description'],
                          owner_id: body['owner_id'].to_i,
                          start_date: body['start_date'],
                          end_date: body['end_date']
                        })
  if new_event.save
    status 201
    { success: true, event: new_event.response_json }.to_json
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
