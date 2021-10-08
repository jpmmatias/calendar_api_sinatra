class CreateInvites
  attr_accessor :event

  def initialize(params, body, user)
    @params = params
    @body = body
    @user = user
    @event = Event.find_by(id: params['event_id'].to_i)
  end

  def call
    validate
    create_invites
  rescue StandardError => e
    e
  end

  def self.with_csv(emails, event_id, user_id)
    emails.map do |email|
      receiver = User.find_by(email: email)
      ValidateInvite.new(receiver, event_id, user_id).call
      invite = Invite.create({ event_id: event_id.to_i, sender_id: user_id, receiver_id: receiver.id })
      InviteSerializer.new(invite).response
    end
  rescue StandardError => e
    e.message
  end

  private

  attr_reader :params

  def create_invites
    return [create_invite] unless @body['users_emails']

    @body['users_emails'].map do |email|
      receiver(email)
      create_invite
    end
  end

  def create_invite
    invite_already_made?
    invite_for_the_owner?
    user_invinting_himslef?
    invite = Invite.create({ event_id: @event.id, sender_id: @user['id'], receiver_id: @receiver.id })
    InviteSerializer.new(invite).response
  rescue NoMethodError
    raise StandardError, "Couldn't find User with this email"
  end

  def validate
    existe_evento
    email_and_id
    multiple_emails
    event_already_passed
  end

  def existe_evento
    raise StandardError, 'Event not found' unless event
  end

  def invite_for_the_owner?
    raise StandardError, 'User alredy invited' if event.owner_id == @receiver.id
  end

  def user_invinting_himslef?
    raise StandardError, 'User alredy invited' if @user['id'] == @receiver.id
  end

  def email_and_id
    raise StandardError, 'Send email or the ID from the user, but not both' if @body['user_id'] && @body['users_emails']
  end

  def multiple_emails
    raise StandardError, 'Send your guests' unless @body['users_emails'] || receiver
  end

  def invite_already_made?
    raise StandardError, 'User already invited' if Invite.where(
      'receiver_id = ? and event_id = ?',
      @receiver.id.to_s,
      @event.id.to_s
    ).any?
  end

  def receiver(email = nil)
    @receiver = @body['user_id'].nil? ? User.find_by(email: email) : User.find(@body['user_id'])
  end

  def event_already_passed
    raise StandardError, 'Event day already passed' if event.event_day_already_passed?
  end
end
