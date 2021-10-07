require 'sidekiq'
require 'csv'
class CreateMultipleEventsWorker
  include Sidekiq::Worker

  def perform(csv, user)
    csv = CSV.parse(csv, headers: true, skip_blanks: true)
    CreateEventsWithCSV.new(csv, user).call
  end
end
