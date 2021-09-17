class ValidateInvite
  def initialize(receiver, event_id, user_id)
    @receiver = receiver
    @user_id = user_id
    @event_id = event_id
  end

  def call
    recevier_exists_csv?
    invite_already_made_csv?
    invite_for_the_owner_csv?
    user_invinting_himslef_csv?
  end

  private

  def recevier_exists_csv?
    raise StandardError, 'Error on users invitation, please try again' if @receiver.nil?
  end

  def invite_already_made_csv?
    raise StandardError, 'User already invited' if Invite.where(
      'receiver_id = ? and event_id = ?',
      @receiver.id.to_s,
      @event_id.to_s
    ).any?
  end

  def invite_for_the_owner_csv?
    event = Event.find(@event_id)
    raise StandardError, 'User alredy invited' if event.owner_id == @receiver.id
  end

  def user_invinting_himslef_csv?
    raise StandardError, 'User alredy invited' if @user_id == @receiver.id
  end
end
