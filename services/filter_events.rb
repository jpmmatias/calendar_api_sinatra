class FilterEvents
  def initialize(params, events)
    @events = events
    @params = params
  end

  def call
    return filtered_events_with_just_start_date if end_date.nil?
    return filtered_events_with_just_end_date if start_date.nil?

    filtered_events
  rescue StandardError => e
    e.message
  end

  private

  def start_date
    @start_date ||= @params['start_date'] ? DateTime.parse(@params['start_date']) : nil
  rescue ArgumentError
    raise StandardError, 'Parâmetros de filtros invalidos, tente novamente'
  end

  def end_date
    @end_date ||= @params['end_date'] ? DateTime.parse(@params['end_date']) : nil
  rescue ArgumentError
    raise StandardError, 'Parâmetros de filtros invalidos, tente novamente'
  end

  def filtered_events_with_just_start_date
    @events.select { |event| event.start_date >= start_date }
  end

  def filtered_events_with_just_end_date
    @events.select { |event| event.end_date <= end_date }
  end

  def filtered_events
    @events.select { |event| event.start_date >= start_date && event.end_date <= end_date }
  end
end
