class Invite < ActiveRecord::Base
  enum status: { unanswered: 0, accepted: 1, refused: 2, perhaps: 3 }
  belongs_to :user, class_name: 'User', foreign_key: 'sender_id'
  belongs_to :user, class_name: 'User', foreign_key: 'reciver_id'
  belongs_to :event

  def response_json
    event = Event.find(event_id)
    sender = User.find(sender_id)
    { event_name: event.name, sender_name: sender.name, event_start_date: event.start_date.to_s,
      event_end_date: event.end_date.to_s }.as_json
  end
end
