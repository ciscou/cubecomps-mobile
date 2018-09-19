json.cache! ['api', 'v1', @competitions], ccm_cache_options do
  json.in_progress @competitions.in_progress,    :id, :name, :city, :date
  json.past        @competitions.past.first(10), :id, :name, :city, :date
  json.upcoming    @competitions.upcoming,       :id, :name, :city, :date
end
