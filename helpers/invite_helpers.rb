helpers do
  def invite_already_made?(reciver, event_id)
    Invite.where('receiver_id = ? and event_id = ?',
                 reciver.id.to_s,
                 event_id.to_s).any?
  end

  def available_invites_from_user(id)
    invites = Invite.where('receiver_id= ? and status = ?', id.to_s, '0')
    invites.map { |invite| InviteSerializer.new(invite).response }
  end

  def invitation_successed?(event_id, emails, user_id)
    results = create_invites_and_return_success(emails, event_id, user_id)
    !results.include?(false)
  end

  def create_invites_and_return_success(emails, event_id, user_id, events = nil)
    emails.map do |email|
      reciver = User.find_by(email: email)
      invite = Invite.new({ event_id: event_id.to_i, sender_id: user_id, receiver_id: reciver.id })
      event_day_already_check_and_save(invite)
    rescue NoMethodError
      events&.map { |id| Event.destroy(id) }
      false
    end
  end

  def event_day_already_check_and_save(invite)
    if invite.event_day_already_passed?
      false
    else
      invite.save
    end
  end

  def get_receiver(user_email, user_id)
    user_id ? User.find(user_id) : User.find_by(email: user_email)
  end

  def multiple_emails?(emails)
    emails ? true : false
  end
end
