json.cache! [@competition, "schedule"], ccm_cache_options(@competition.id, expires_in: 1.hour) do
  json.array! @competition.schedule do |row|
    json.extract! row, :start, :end, :event_code, :alternate_text, :round_name, :extra_info, :am_pm_format
  end
end
