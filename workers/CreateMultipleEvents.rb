require 'sidekiq'
class CreateMultipleEventsWorker
  include Sidekiq::Worker

  def perform(csv, user)
    binding.pry
    CreateEventsWithCSV.new(csv, user).call
  end
end
