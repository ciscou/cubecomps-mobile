json.cache! [Tenant.current, @competitions], ccm_cache_options do
  json.in_progress @competitions.in_progress,    :id, :name, :city, :country, :date
  json.past        @competitions.past.first(25), :id, :name, :city, :country, :date
  json.upcoming    @competitions.upcoming,       :id, :name, :city, :country, :date
end
