json.cache! [@competition, "events"], expires_in: 5.minutes, race_condition_ttl: 10 do
  json.array! @competition.events do |json, event|
    json.extract! event, :name
    json.rounds event.rounds do |json, round|
      json.extract! round, :competition_id, :event_id, :id, :name
    end
  end
end
