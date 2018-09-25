class Event
  CODE_TO_NAME = {
    "333"    => "3x3x3 Cube",
    "222"    => "2x2x2 Cube",
    "444"    => "4x4x4 Cube",
    "555"    => "5x5x5 Cube",
    "666"    => "6x6x6 Cube",
    "777"    => "7x7x7 Cube",
    "clock"  => "Clock",
    "magic"  => "Magic",
    "mmagic" => "Master Magic",
    "minx"   => "Megaminx",
    "pyram"  => "Pyraminx",
    "sq1"    => "Square-1",
    "333oh"  => "3x3x3 One-Handed",
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

  NAME_TO_ID = Hash[CODE_TO_NAME.map.with_index do |(code, name), index|
    [name, index + 1]
  end]

  attr_accessor :id, :name, :rounds

  def initialize(args)
    args.each do |k, v|
      send("#{k}=", v)
    end
  end

  def self.build_from_event_td(event_td)
    event_name = event_td.css("div.event, div.c_event").text
    unless ["", "Competitors", "Schedule"].include? event_name
      event_rounds = event_td.css("div.round, div.c_round").map do |round_div|
        Round.build_from_round_div(round_div)
      end

      event_id = event_rounds.first.event_id || NAME_TO_ID[event_name]

      new(
        id:     event_id,
        name:   event_name,
        rounds: event_rounds
      )
    end
  end

  def best_record(records_cache = nil)
    best_records = rounds.map { |round| round.best_record(records_cache) }
    best_records.delete("WR") ||
    best_records.delete("CR") ||
    best_records.delete("NR")
  end

  def live?(past_cache = nil)
    rounds.any? { |round| round.live?(past_cache) }
  end

  def finished?(past_cache = nil)
    rounds.all? { |round| round.finished?(past_cache) }
  end

  def to_param
    id.to_s
  end
end
