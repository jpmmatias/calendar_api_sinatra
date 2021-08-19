get '/v1/events' do
  events = Event.all
  status 204 if events.empty?
  events.to_json
end

get '/v1/events/:id' do
  Event.where(id: params['id']).first.to_json
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
    { success: true }.to_json
  else
    puts 'Erro'
  end
end

private

def get_body(req)
  req.body.rewind
  JSON.parse(req.body.read)
end
