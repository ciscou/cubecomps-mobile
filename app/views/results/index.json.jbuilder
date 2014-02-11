json.cache! [@round, "results"], expires_in: 5.minutes, race_condition_ttl: 10 do
  json.array! @round.results do |result|
    json.extract! result, :position, :name, :country

    json.t1 result.t1 if @round.results.t1?
    json.t2 result.t2 if @round.results.t2?
    json.t3 result.t3 if @round.results.t3?
    json.t4 result.t4 if @round.results.t4?
    json.t5 result.t5 if @round.results.t5?

    json.average result.average if @round.results.average?
    json.mean    result.mean    if @round.results.mean?
    json.best    result.best    if @round.results.best?
  end
end
