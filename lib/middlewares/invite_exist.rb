class InviteExist
  def initialize(app)
    @app = app
  end

  def call(env)
    @env = env

    return @app.call @env unless invite_token_routes

    return [404, { 'Content-Type' => 'application/json' }, { error: 'Invite not found' }.to_json] if invite.nil?

    @app.call @env
  end

  private

  def invite_token_routes
    path_info_splited[2] == 'invites' && !path_info_splited[3].nil? && @env['REQUEST_METHOD'] != 'GET'
  end

  def invite
    Invite.find_by(token: invite_token)
  end

  def path_info_splited
    @env['PATH_INFO'].split('/')
  end

  def invite_token
    path_info_splited[3]
  end
end
