get '/v1/events' do
  events = Event.all
  response_body(200, events, :documents)
end

get '/v1/events/:id' do
  event = Event.where(id: params['id']).first
  return status 404 if event.nil?

  response_body(200, event, :documents)
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
    response_body(201, new_event)
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

def error(message)
  { error: message }.to_json
end

def response_body(status, body, include = nil)
  return [status(status), body.to_json] if include.nil?

  [status(status), body.as_json(include: include).to_json]
end
