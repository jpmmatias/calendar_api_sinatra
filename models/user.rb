class User < ActiveRecord::Base
  has_secure_password
  has_many :events, foreign_key: 'owner_id'
  has_many :invites, foreign_key: 'sender_id'
  has_many :invites, foreign_key: 'receiver_id'
  validates :name,  presence: true
  validates :email, presence: true, uniqueness: true,
                    format: { with: /\w+@\w+\.\w+/ }
  validates :password, presence: true
end
