json.cache! [Tenant.current, 'api', 'v2', @competitions], ccm_cache_options do
  json.in_progress @competitions.in_progress,    :id, :name, :city, :country, :country_code, :date
  json.past        @competitions.past.first(25), :id, :name, :city, :country, :country_code, :date
  json.upcoming    @competitions.upcoming,       :id, :name, :city, :country, :country_code, :date
end
