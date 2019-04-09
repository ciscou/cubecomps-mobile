json.cache! [Tenant.current, @competition, "competitors"], ccm_cache_options(competition_id: @competition.id) do
  json.array! @competition.competitors do |competitor|
    json.extract! competitor, :competition_id, :id, :name
  end
end
