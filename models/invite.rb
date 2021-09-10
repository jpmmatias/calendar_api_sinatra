class Invite < ActiveRecord::Base
  enum status: { unanswered: 0, accepted: 1, refused: 2, perhaps: 3 }
  belongs_to :user, class_name: 'User', foreign_key: 'sender_id'
  belongs_to :user, class_name: 'User', foreign_key: 'reciver_id'
  belongs_to :event
end
