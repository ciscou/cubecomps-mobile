class Event
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
      new(
        id:     event_rounds.first.event_id,
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
