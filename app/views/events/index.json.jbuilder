json.cache! [@competition, "events"], ccm_cache_options(@competition.id) do
  json.array! @competition.events do |json, event|
    json.extract! event, :name
    json.rounds event.rounds do |json, round|
      json.extract! round, :competition_id, :event_id, :id, :name
    end
  end
end
