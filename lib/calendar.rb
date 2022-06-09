class Calendar
  def initialize(service, calendar_owner_id, negative_titles)
    @service = service
    @calendar_id = calendar_owner_id
    @negative_titles = negative_titles
  end

  def event_items(date)
    items = @service.list_events(
      @calendar_id,
      single_events: true,
      time_min: date.beginning_of_day.iso8601,
      time_max: date.end_of_day.iso8601,
      order_by: 'startTime'
    ).items

    # メソッドチェーンにしたかったのに間違えた
    items = remove_private_items(items)
    items = remove_negative_title_items(items) if @negative_titles.present?

    filter_accepted_items(items)
  end

  def remove_private_items(items)
    items.filter { |item| item.visibility != "private" }
  end

  def remove_negative_title_items(items)
    items.filter { |item| !@negative_titles.include?(item.summary) }
  end

  def filter_accepted_items(items)
    items.filter do |item|
      # ゲストが0 → 自分向け作業
      # ゲストである自分が "不参加" でない
      item.attendees.nil? or item.attendees.find do |attendee|
        attendee.self && attendee.response_status != "declined"
      end
    end
  end
end
