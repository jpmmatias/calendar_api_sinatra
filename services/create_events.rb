class CreateEventsWithCSV
  def initialize(csv, user)
    @csv = csv
    @user = user
  end

  def call
    create_event_and_invites
  rescue StandardError => e
    e
  end

  def create_event_and_invites
    @csv.map do |event|
      new_event = create_event(event, @user['id'])
      emails = get_emails_from_event(event, @user['email'])
      invites = CreateInvites.with_csv(emails, new_event.id, @user['id'])
      raise StandardError, invites if invites.is_a?(String)

      EventSerializer.new(new_event).response
    end
  end

  private

  attr_reader :params

  def create_event(event, user_id)
    Event.create!(
      name: event['Nome de Evento'], local: event['Localidade'],
      description: event['Descrição'],
      start_date: DateTime.parse(event['Data e Hora Inicio']),
      end_date: DateTime.parse(event['Data e Hora Fim']),
      owner_id: user_id
    )
  rescue ActiveRecord::RecordInvalid => e
    raise StandardError, e.message
  end

  def rescue_active_record
  rescue ActiveRecord::RecordInvalid => e
    raise StandardError, e.message
  end

  def get_emails_from_event(event, user_email)
    event['Participantes'].delete(' ').split(',').reject { |email| email == user_email }
  end

  def non_existing_event(event_id)
    Event.find(event_id).nil?
  end
end
