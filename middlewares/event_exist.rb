class EventExist
  def initialize(app)
    @app = app
  end

  def call(env)
    @env = env

    return @app.call @env unless event_routes

    return [404, { 'Content-Type' => 'application/json' }, { error: 'Event not found' }.to_json] if this_event.nil?

    @app.call @env
  end

  private

  def event_routes
    path_info_splited[2] == 'events' && event_id_integer?
  end

  def path_info_splited
    @env['PATH_INFO'].split('/')
  end

  def this_event
    Event.find_by(id: event_id)
  end

  def event_id_integer?
    return event_id.scan(/\D/).empty? && event_id != '' if event_id

    false
  end

  def event_id
    path_info_splited[3]
  end
end
