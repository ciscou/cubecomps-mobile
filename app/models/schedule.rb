class Schedule
  attr_accessor :start, :end, :event_code, :alternate_text, :round_id, :round_name, :extra_info, :am_pm_format

  def initialize(args)
    args.each do |k, v|
      send("#{k}=", v)
    end
  end

  def formatted_start
    start.strftime(time_format)
  end

  def formatted_end
    self.end.strftime(time_format)
  end

  def time_format
    if am_pm_format
      "%I:%M"
    else
      "%H:%M"
    end
  end

  def event_id
    index = Event::CODE_TO_NAME.keys.index(event_code) || 999
    index + 1
  end

  def event_name
    Event::CODE_TO_NAME.fetch(event_code) { event_code }
  end

  def round_started?(competition_id)
    Round.new(competition_id: competition_id, event_id: event_id, id: round_id).started?
  end
end
