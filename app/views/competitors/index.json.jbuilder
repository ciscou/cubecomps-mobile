json.cache! [@competition, "competitors"], expires_in: 5.minutes, race_condition_ttl: 10 do
  json.array! @competition.competitors do |json, competitor|
    json.extract! competitor, :competition_id, :id, :name
  end
end
