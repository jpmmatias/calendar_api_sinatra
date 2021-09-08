get '/v1/events' do
  user = request.env[:user]

  events = Event.where(owner_id: user['id'])
  events = events.map { |event| event.response_json }
  response_body(200, events, :documents)
end

get '/v1/events/:id' do
  user = request.env[:user]
  event = Event.where(['id = ? and owner_id = ?', params['id'].to_s, user['id'].to_s]).first
  return status 404 if event.nil?

  response_body(200, event.response_json, :documents)
end

post '/v1/events' do
  user = request.env[:user]
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
    response_body(201, new_event.response_json)
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

def response_body(status, body, include = nil)
  return [status(status), body.to_json] if include.nil?

  [status(status), body.as_json(include: include).to_json]
end
