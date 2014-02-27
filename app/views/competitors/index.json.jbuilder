json.cache! [@competition, "competitors"], ccm_cache_options(@competition.id) do
  json.array! @competition.competitors do |json, competitor|
    json.extract! competitor, :competition_id, :id, :name
  end
end
