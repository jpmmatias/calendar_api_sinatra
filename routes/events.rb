require 'csv'
get '/v1/events' do
  events = user.all_events

  events = events.map { |event| EventSerializer.new(event).response }
  response_body(200, events)
end

get '/v1/events/:id' do
  serialized_event = EventSerializer.new(event).response
  response_body(200, serialized_event)
end

post '/v1/events' do
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

post '/v1/events/csv' do
  unless params[:file].nil?
    csv = params[:file][:tempfile].read.force_encoding('UTF-8')
    CreateMultipleEventsWorker.perform_async(csv, user)
    return status 200
  end

  response_body(400, { error: 'Send a CSV File' })
end

put '/v1/events/:id' do
  body = get_body(request)

  if event.update(body)
    this_event = EventSerializer.new(event).response
    response_body(200, this_event)
  else
    response_body(400, { error: 'Error when update event, please try again' })
  end
end

delete '/v1/events/:id' do
  event.destroy
  status 204
end

private
