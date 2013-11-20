json.cache! [@round, "results"], expires_in: 5.minutes, race_condition_ttl: 10 do
  json.array! @round.results do |result|
    json.extract! result, :position, :name, :country

    json.t1 result.t1 if @round.t1?
    json.t2 result.t2 if @round.t2?
    json.t3 result.t3 if @round.t3?
    json.t4 result.t4 if @round.t4?
    json.t5 result.t5 if @round.t5?

    json.average result.average if @round.average?
    json.mean    result.mean    if @round.mean?
    json.best    result.best    if @round.best?
  end
end
