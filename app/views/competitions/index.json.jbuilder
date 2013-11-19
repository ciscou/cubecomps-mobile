json.cache! @competitions, expires_in: 5.minutes, race_condition_ttl: 10 do
  json.in_progress @competitions.in_progress,    :id, :name
  json.past        @competitions.past.first(10), :id, :name
  json.upcoming    @competitions.upcoming,       :id, :name
end
