json.cache! ['api', 'v1', @competition], ccm_cache_options(competition_id: @competition.id) do
  json.name @competition.name
  json.city @competition.city
  json.country @competition.country
  json.date @competition.date
  json.events @competition.events do |event|
    json.extract! event, :id, :name
    json.best_record event.best_record(@competition.records_cache)
    json.live event.live?(@competition.past?)
    json.finished event.finished?(@competition.past?)
    json.rounds event.rounds do |round|
      json.extract! round, :competition_id, :event_id, :id, :name
      json.best_record round.best_record(@competition.records_cache)
      json.live round.live?(@competition.past?)
      json.finished round.finished?(@competition.past?)
    end
  end
  json.competitors @competition.competitors do |competitor|
    json.extract! competitor, :competition_id, :id, :name
  end
  json.schedule do
    @competition.schedule.group_by { |row| row.start.to_date.to_s(:long) }.each do |date, rows|
      json.set! date do
        json.array! rows.sort_by { |row| [row.start, row.end] } do |row|
          json.extract! row, :start, :end, :formatted_start, :formatted_end, :event_code, :event_id, :event_name, :alternate_text, :round_name, :round_id, :extra_info, :am_pm_format
          json.round_started row.round_started?(@competition)
          json.competition_id @competition.id
        end
      end
    end
  end
end
