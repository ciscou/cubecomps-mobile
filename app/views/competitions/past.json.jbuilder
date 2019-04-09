json.cache! [Tenant.current, @competitions, "past"], ccm_cache_options(expires_in: 1.hour) do
  json.past @competitions.past, :id, :name, :date, :city
end
