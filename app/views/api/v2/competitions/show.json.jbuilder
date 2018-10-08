json.cache! ['api', 'v1', @competition], ccm_cache_options(competition_id: @competition.id) do
  json.name @competition.name
  json.city @competition.city
  json.country @competition.country
  json.events @competition.events do |event|
    event.rounds.each do |round|
      round.past_cache        = @competition.past?
      round.best_record_cache = @competition.records_cache
      round.updated_at_cache  = @competition.updated_at_cache
    end
    json.extract! event, :id, :code
    json.best_record event.best_record
    json.live event.live?
    json.finished event.finished?
    json.rounds event.rounds do |round|
      json.extract! round, :id, :code, :event_id, :event_code
      json.best_record round.best_record
      json.live round.live?
      json.finished round.finished?
    end
  end
  json.competitors @competition.competitors do |competitor|
    json.extract! competitor, :id, :name
  end
  json.schedule do
    json.array! @competition.schedule.group_by { |row| row.start.to_date.to_s(:long) } do |day, rows|
      json.day day
      json.rows rows.sort_by { |row| [row.start, row.end] } do |row|
        json.extract! row, :formatted_start, :formatted_end, :event_id, :event_code, :round_id, :round_code, :alternate_text, :extra_info
        unless %w[reg lun tro].include? row.round_code
          json.round_started Round.new(competition_id: @competition.id, event_id: row.event_id, id: row.round_id, past_cache: @competition.past?, updated_at_cache: @competition.updated_at_cache, best_record_cache: @competition.records_cache).started?
        end
      end
    end
  end
end
