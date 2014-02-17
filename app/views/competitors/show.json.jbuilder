json.cache! [@competitor, "results"], expires_in: 5.minutes, race_condition_ttl: 10 do
  json.array! @competitor.results do |json, result|
    json.extract! result, :position, :event, :round

    json.t1 result.t1 if @competitor.results.t1?
    json.t2 result.t2 if @competitor.results.t2?
    json.t3 result.t3 if @competitor.results.t3?
    json.t4 result.t4 if @competitor.results.t4?
    json.t5 result.t5 if @competitor.results.t5?

    json.average result.average if @competitor.results.average?
    json.mean    result.mean    if @competitor.results.mean?
    json.best    result.best    if @competitor.results.best?
  end
end