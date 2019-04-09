json.cache! [Tenant.current, 'api', 'v1', @competitions, "past"], ccm_cache_options(expires_in: 1.hour) do
  json.past @competitions.past, :id, :name, :date, :city, :country, :country_code
end
