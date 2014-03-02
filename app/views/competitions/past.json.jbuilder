json.cache! [@competitions, "past"], ccm_cache_options do
  json.past @competitions.past, :id, :name
end
