class Event < ActiveRecord::Base
  validates :name, :local, :owner, :description, :start_date, :end_date, presence: true
end
