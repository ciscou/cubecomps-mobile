class Schedule
  EVENTS = {
    "333" => "3x3x3 Cube",
    "222" => "2x2x2 Cube",
    "444" => "4x4x4 Cube",
    "555" => "5x5x5 Cube",
    "666" => "6x6x6 Cube",
    "777" => "7x7x7 Cube",
    "clock" => "Clock",
    "magic" => "Magic",
    "mmagic" => "Master Magic",
    "minx"   => "Megaminx",
    "pyram"  => "Pyraminx",
    "sq1"    => "Square-1",
    "333oh"  => "3x3x3 One Handed",
    "333ft"  => "3x3x3 With Feet",
    "333fm"  => "3x3x3 Fewest Moves",
    "333bf"  => "3x3x3 Blindfolded",
    "444bf"  => "4x4x4 Blindfolded",
    "555bf"  => "5x5x5 Blindfolded",
    "333mbf" => "3x3x3 Multiple Blindfolded",
    "skewb"  => "Skewb",
    "reg"    => "REGISTRATION",
    "lun"    => "LUNCH",
    "tro"    => "AWARDS"
  }

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
    index = EVENTS.keys.index(event_code) || 999
    index + 1
  end

  def event_name
    EVENTS.fetch(event_code) { event_code }
  end

  def round_started?(competition)
    Round.new(competition_id: competition.id, event_id: event_id, id: round_id).started?(competition.past?)
  end
end
