json.cache! [@competitions, "past"], expires_in: 5.minutes, race_condition_ttl: 10 do
  json.past @competitions.past, :id, :name
end
