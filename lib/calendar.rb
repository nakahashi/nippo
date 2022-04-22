class Calendar
  def initialize(service, calendar_owner_id)
    @service = service
    @calendar_id = calendar_owner_id
  end

  def event_items(date)
    @service.list_events(
      @calendar_id,
      single_events: true,
      time_min: date.beginning_of_day.iso8601,
      time_max: date.end_of_day.iso8601,
      order_by: 'startTime'
    ).items
  end
end
