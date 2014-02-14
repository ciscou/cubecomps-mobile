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

  def to_param
    id.to_s
  end
end
