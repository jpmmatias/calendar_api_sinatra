require 'csv'
get '/v1/events' do
  events = user.all_events

  events = events.map { |event| EventSerializer.new(event).response }
  response_body(200, events)
end

get '/v1/events/:id' do
  user_allowed_to_see_event!

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
    csv = CSV.parse(params[:file][:tempfile].read.force_encoding('UTF-8'), headers: true)
    events = CreateEventsWithCSV.new(csv, user).call
    return response_body(201, events) if events.is_a?(Array)

    return response_body(400, { error: events })
  end

  response_body(400, { error: 'Send a CSV File' })
end

put '/v1/events/:id' do
  body = get_body(request)
  return response_body(404, { error: 'Event not found' }) if event.nil?

  user_owner_of_the_event!

  if event.update(body)
    this_event = EventSerializer.new(event).response
    response_body(200, this_event)
  else
    response_body(400, { error: 'Error when update event, please try again' })
  end
end

delete '/v1/events/:id' do
  user_owner_of_the_event!

  event.destroy
  status 204
end
