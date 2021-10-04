class Invite < ActiveRecord::Base
  has_secure_token
  enum status: { unanswered: 0, accepted: 1, refused: 2, perhaps: 3 }
  belongs_to :user, class_name: 'User', foreign_key: 'sender_id'
  belongs_to :user, class_name: 'User', foreign_key: 'receiver_id'
  belongs_to :event
  delegate :event_day_already_passed?, to: :event
end
