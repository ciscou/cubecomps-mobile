json.cache! ['api', 'v1', @round], ccm_cache_options(competition_id: @round.competition_id) do
  json.competition_name @round.competition_name
  json.event_name @round.event_name
  json.round_name @round.name
  json.results @round.results do |result|
    json.extract! result, :position, :top_position, :name, :country
    json.extract! result, :competitor_id

    json.t1 result.t1 if @round.results.t1?
    json.t2 result.t2 if @round.results.t2?
    json.t3 result.t3 if @round.results.t3?
    json.t4 result.t4 if @round.results.t4?
    json.t5 result.t5 if @round.results.t5?

    if @round.results.average?
      json.average        result.average
      json.average_record result.average_record
    end
    if @round.results.mean?
      json.mean        result.mean
      json.mean_record result.mean_record
    end
    if @round.results.best?
      json.best        result.best
      json.best_record result.best_record
    end
  end
end
