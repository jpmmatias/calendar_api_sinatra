class Event < ActiveRecord::Base
  has_many :documents, dependent: :destroy
  belongs_to :user, class_name: 'User', foreign_key: 'owner_id'
  validates :name, :local, :owner_id, :description, :start_date, :end_date, presence: true

  def response_json
    documents = Document.where(event_id: id)
    { name: name, local: local, owner: user, description: description, start_date: start_date,
      end_date: end_date, documents: documents }.as_json
  end
end
