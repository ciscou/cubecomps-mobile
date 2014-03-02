json.cache! @competitions, ccm_cache_options do
  json.in_progress @competitions.in_progress,    :id, :name
  json.past        @competitions.past.first(10), :id, :name
  json.upcoming    @competitions.upcoming,       :id, :name
end
