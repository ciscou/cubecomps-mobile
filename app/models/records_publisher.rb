class RecordsPublisher
  def run
    @there_are_new_records = false
    mailer = RecordsMailer.records(self)
    mailer.deliver if @there_are_new_records
  end

  def for_each_record(&block)
    competitions = get_json('/competitions')
    competitions['in_progress'].each do |competition|
      handle_competition(competition, &block)
    end
  end

  private

  def handle_competition(competition, &block)
    events = get_json('/competitions/%{competition_id}/events' % { competition_id: competition['id'] })
    events.each do |event|
      handle_event(competition, event, &block)
    end
  end

  def handle_event(competition, event, &block)
    event['rounds'].each do |round|
      handle_round(competition, event, round, &block)
    end
  end

  def handle_round(competition, event, round, &block)
    return unless round['event_id'] && round['id']
    return unless round['live']

    results = get_json('/competitions/%{competition_id}/events/%{event_id}/rounds/%{round_id}/results' % { competition_id: competition['id'], event_id: round['event_id'], round_id: round['id'] })

    results.select { |r| r['average_record'] }.each do |result|
      handle_average_record(competition, event, round, result, &block)
    end

    results.select { |r| r['best_record'] }.each do |result|
      handle_best_record(competition, event, round, result, &block)
    end
  end

  def handle_average_record(competition, event, round, result, &block)
    return unless $redis.sadd('published_average_records', [competition['id'], round['event_id'], round['id'], result['name']].join(':'))

    publish_record(competition, event, round, result, "average", &block)
  end

  def handle_best_record(competition, event, round, result, &block)
    return unless $redis.sadd('published_best_records', [competition['id'], round['event_id'], round['id'], result['name']].join(':'))

    publish_record(competition, event, round, result, "best", &block)
  end

  def publish_record(competition, event, round, result, type, &block)
    @there_are_new_records = true

    description = "%{competitor_name} (from %{competitor_country}) just got the %{event_name} %{type} %{record} (%{time}) at %{competition_name}" % {
      competitor_name: result['name'],
      competitor_country: result['country'],
      event_name: event['name'],
      type: type == "best" ? "single" : type,
      record: result["#{type}_record"],
      time: result[type],
      competition_name: competition['name']
    }

    url = "http://cubecomps.com/live.php?cid=%{competition_id}&cat=%{event_id}&rnd=%{round_id}" % {
      competition_id: competition['id'],
      event_id: round['event_id'],
      round_id: round['id']
    }

    block.call description, url
  end

  def get_json(path)
    response = Net::HTTP.get_response('m.cubecomps.com', "#{path}.json")
    JSON.parse response.body
  end
end
