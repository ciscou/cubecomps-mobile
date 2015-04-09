json.cache! [@competitions, "past"], expires_in: 1.hour, ccm_cache_options do
  json.past @competitions.past, :id, :name
end
