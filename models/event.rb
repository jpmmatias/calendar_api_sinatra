class Event < ActiveRecord::Base
  has_many :documents, dependent: :destroy
  belongs_to :user, class_name: 'User', foreign_key: 'owner_id'
  validates :name, :local, :owner_id, :description, :start_date, :end_date, presence: true
end
