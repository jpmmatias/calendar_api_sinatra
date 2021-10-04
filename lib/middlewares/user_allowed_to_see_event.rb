class UserAllowedToSeeEvent
  def initialize(app)
    @app = app
  end

  def call(env)
    @env = env

    return @app.call @env unless event_routes

    return [404, { 'Content-Type' => 'application/json' }, { error: 'Event not found' }.to_json] if this_event.nil?

    user_id = @env[:user]['id']

    allowed = accepted_invites.map(&:receiver_id).unshift(this_event.owner_id).include?(user_id)

    return [403, { 'Content-Type' => 'application/json' }, { error: 'User not allowed' }.to_json] unless allowed

    @app.call @env
  end

  private

  def accepted_invites
    Invite.where('event_id = ? and status = ?', this_event.id.to_s, '1')
  end

  def event_routes
    path_info_splited[2] == 'events' && event_id_integer? && @env['REQUEST_METHOD'] == 'GET'
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
