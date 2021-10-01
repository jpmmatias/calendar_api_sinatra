class UserAllowedToSeeInvite
  def initialize(app)
    @app = app
  end

  def call(env)
    @env = env

    return @app.call @env unless invite_get_routes

    return [404, { 'Content-Type' => 'application/json' }, { error: 'Invite not found' }.to_json] if invite.nil?

    user_id = @env[:user]['id']

    allowed = user_id == invite.sender_id || user_id == invite.receiver_id

    return [403, { 'Content-Type' => 'application/json' }, { error: 'User not allowed' }.to_json] unless allowed

    @app.call @env
  end

  private

  def invite
    Invite.find_by(token: invite_token)
  end

  def invite_get_routes
    path_info_splited[2] == 'invites' && !path_info_splited[3].nil? && @env['REQUEST_METHOD'] == 'GET'
  end

  def path_info_splited
    @env['PATH_INFO'].split('/')
  end

  def invite_token
    path_info_splited[3]
  end
end
