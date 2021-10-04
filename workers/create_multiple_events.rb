class CreateMultipleEvents
  include Sidekiq::Worker
  def peform(csv, user)
    CreateEventsWithCSV.new(csv, user).call
  end
end
