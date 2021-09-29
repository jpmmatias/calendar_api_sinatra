require 'sidekiq'
class SinatraWorker
  include Sidekiq::Worker
  def create_multiple_events
    csv = CSV.parse(params[:file][:tempfile].read.force_encoding('UTF-8'), headers: true)
    CreateEventsWithCSV.new(csv, user).call
  end
end
