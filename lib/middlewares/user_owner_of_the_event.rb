class UserOwnerOfTheEvent
  def initialize(app)
    @app = app
  end

  def call(env)
    @env = env

    return @app.call @env unless event_owner_only_routes

    return [404, { 'Content-Type' => 'application/json' }, { error: 'Invite not found' }.to_json] if event.nil?

    user_id = @env[:user]['id']

    allowed = event.owner_id == user_id

    return [403, { 'Content-Type' => 'application/json' }, { error: 'User not allowed' }.to_json] unless allowed

    @app.call @env
  end

  private

  def event
    Event.find_by(id: event_id)
  end

  def event_owner_only_routes
    path_info_splited[2] == 'events' && !event_id.nil? && (@env['REQUEST_METHOD'] == 'PUT' || @env['REQUEST_METHOD'] == 'DELETE')
  end

  def path_info_splited
    @env['PATH_INFO'].split('/')
  end

  def event_id
    path_info_splited[3]
  end
end
