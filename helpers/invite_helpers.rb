class InviteHelper
  def self.invite_already_made?(reciver, event_id)
    !Invite.where('receiver_id = ? and event_id = ?',
                  reciver.id.to_s,
                  event_id.to_s).empty?
  end

  def self.available_invites_from_user(id)
    invites = Invite.where('receiver_id= ? and status = ?', id.to_s, '0')
    invites.map { |invite| InviteSerializer.new(invite).response }
  end

  def self.invitation_successed?(event_id, emails, user_id)
    results = create_invites_and_return_success(emails, event_id, user_id)
    return true if !results.include?(false)

    false
  end

  def self.create_invites_and_return_success(emails, event_id, user_id)
    emails.map do |email|
      reciver = User.find_by(email: email)
      invite = Invite.new({ event_id: event_id.to_i, sender_id: user_id, receiver_id: reciver.id })

      if invite.event_day_already_passed?
        false
      else
        invite.save
      end
    end
  end
end
