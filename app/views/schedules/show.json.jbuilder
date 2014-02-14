json.cache! [@competition, "schedule"], expires_in: 1.hour, race_condition_ttl: 10 do
  json.array! @competition.schedule do |row|
    json.extract! row, :start, :end, :event_code, :alternate_text, :round_name, :extra_info, :am_pm_format
  end
end
