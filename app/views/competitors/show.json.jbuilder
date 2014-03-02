json.cache! [@competitor, "results"], ccm_cache_options(competition_id: @competitor.competition_id) do
  json.array! @competitor.results do |result|
    json.extract! result, :position, :event, :round

    json.t1 result.t1 if @competitor.results.t1?
    json.t2 result.t2 if @competitor.results.t2?
    json.t3 result.t3 if @competitor.results.t3?
    json.t4 result.t4 if @competitor.results.t4?
    json.t5 result.t5 if @competitor.results.t5?

    if @competitor.results.average?
      json.average        result.average
      json.average_record result.average_record
    end
    if @competitor.results.mean?
      json.mean        result.mean
      json.mean_record result.mean_record
    end
    if @competitor.results.best?
      json.best        result.best
      json.best_record result.best_record
    end
  end
end
