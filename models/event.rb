class Event < ActiveRecord::Base
  has_many :documents, dependent: :destroy 
  validates :name, :local, :owner, :description, :start_date, :end_date, presence: true
end
