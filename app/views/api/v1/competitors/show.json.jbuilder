json.cache! ['api', 'v1', @competitor], ccm_cache_options(competition_id: @competitor.competition_id) do
  json.competition_name @competitor.competition_name
  json.name @competitor.name
  json.wca_id @competitor.wca_id
  json.results do
    @competitor.results.by_event.each do |event, results|
      json.set! event do
        json.array! results do |result|
          json.extract! result, :position, :top_position, :event, :round
          json.extract! result, :event_id, :round_id

          json.t1 format_time(result.t1) if @competitor.results.t1?
          json.t2 format_time(result.t2) if @competitor.results.t2?
          json.t3 format_time(result.t3) if @competitor.results.t3?
          json.t4 format_time(result.t4) if @competitor.results.t4?
          json.t5 format_time(result.t5) if @competitor.results.t5?

          if @competitor.results.average?
            json.average        format_time(result.average)
            json.average_record result.average_record
          end
          if @competitor.results.mean?
            json.mean        format_time(result.mean)
            json.mean_record result.mean_record
          end
          if @competitor.results.best?
            json.best        format_time(result.best)
            json.best_record result.best_record
          end
        end
      end
    end
  end
end
