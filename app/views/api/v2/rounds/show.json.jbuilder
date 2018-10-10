json.cache! ['api', 'v2', @round], ccm_cache_options(competition_id: @round.competition_id) do
  json.competition_name @round.competition_name
  json.competition_city @round.competition_city
  json.competition_country @round.competition_country
  json.event_code @round.event_code
  json.code @round.code
  json.results @round.results do |result|
    json.extract! result, :competitor_id, :position, :top_position, :name, :country

    json.t1 format_time(result.t1) if @round.results.t1?
    json.t2 format_time(result.t2) if @round.results.t2?
    json.t3 format_time(result.t3) if @round.results.t3?
    json.t4 format_time(result.t4) if @round.results.t4?
    json.t5 format_time(result.t5) if @round.results.t5?

    if @round.results.average?
      json.average        format_time(result.average)
      json.average_record result.average_record
    end
    if @round.results.mean?
      json.mean        format_time(result.mean)
      json.mean_record result.mean_record
    end
    if @round.results.best?
      json.best        format_time(result.best)
      json.best_record result.best_record
    end
  end
end
