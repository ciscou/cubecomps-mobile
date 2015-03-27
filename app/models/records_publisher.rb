class RecordsPublisher
  def run
    competitions = get_json('/competitions')
    competitions['in_progress'].each do |competition|
      handle_competition(competition)
    end
  rescue => e
    ExceptionNotifier.notify_exception(e)
  end

  private

  def handle_competition(competition)
    events = get_json('/competitions/%{competition_id}/events' % { competition_id: competition['id'] })
    events.each do |event|
      handle_event(competition, event)
    end
  end

  def handle_event(competition, event)
    event['rounds'].each do |round|
      handle_round(competition, event, round)
    end
  end

  def handle_round(competition, event, round)
    return unless round['event_id'] && round['id']

    results = get_json('/competitions/%{competition_id}/events/%{event_id}/rounds/%{round_id}/results' % { competition_id: competition['id'], event_id: round['event_id'], round_id: round['id'] })

    results.select { |r| r['average_record'] }.each do |result|
      handle_average_record(competition, event, round, result)
    end

    results.select { |r| r['mean_record'] }.each do |result|
      handle_mean_record(competition, event, round, result)
    end

    results.select { |r| r['best_record'] }.each do |result|
      handle_best_record(competition, event, round, result)
    end
  end

  def handle_average_record(competition, event, round, result)
    return unless $redis.sadd('published_average_records', [competition['id'], round['event_id'], round['id'], result['competitor_id']].join(':'))

    publish_record(competition, event, round, result, "average")
  end

  def handle_mean_record(competition, event, round, result)
    return unless $redis.sadd('published_mean_records', [competition['id'], round['event_id'], round['id'], result['competitor_id']].join(':'))

    publish_record(competition, event, round, result, "mean")
  end

  def handle_best_record(competition, event, round, result)
    return unless $redis.sadd('published_best_records', [competition['id'], round['event_id'], round['id'], result['competitor_id']].join(':'))

    publish_record(competition, event, round, result, "best")
  end

  def publish_record(competition, event, round, result, type)
    description = "%{competitor_name} (from %{competitor_country}) just got the %{event_name} %{type} %{record} (%{time}) at %{competition_name}" % {
      competitor_name: result['name'],
      competitor_country: result['country'],
      event_name: publishable_event_name(event['name']),
      type: type == "best" ? "single" : "average",
      record: result["#{type}_record"],
      time: result[type],
      competition_name: competition['name']
    }

    url = "http://cubecomps.com/live.php?cid=%{competition_id}&cat=%{event_id}&rnd=%{round_id}" % {
      competition_id: competition['id'],
      event_id: round['event_id'],
      round_id: round['id']
    }

    status = [description, url].join(" ")
    tweet(status)
  end

  def tweet(status)
    twitter_client.update(status)
  rescue => e
    ExceptionNotifier.notify_exception(e, data: { status: status })
  end

  def publishable_event_name(event_name)
    {
      "Rubik's Cube: Blindfolded"          => "3x3x3 Bld",
      "Rubik's Cube: One-handed"           => "3x3x3 OH",
      "Rubik's Cube: Fewest moves"         => "3x3x3 FMC",
      "Rubik's Cube: With Feet"            => "3x3x3 WF",
      "2x2x2 Cube"                         => "2x2x2",
      "4x4x4 Cube"                         => "4x4x4",
      "5x5x5 Cube"                         => "5x5x5",
      "6x6x6 Cube"                         => "6x6x6",
      "7x7x7 Cube"                         => "7x7x7",
      "4x4x4 Cube: Blindfolded"            => "4x4x4 Bld",
      "5x5x5 Cube: Blindfolded"            => "5x5x5 Bld",
      "Rubik's Cube: Multiple Blindfolded" => "3x3x3 Multi Bld",
    }.fetch(event_name, event_name)
  end

  def twitter_client
    if Rails.env.production?
      Twitter::REST::Client.new do |config|
        config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
        config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
        config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
        config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
      end
    else
      FakeTwitterClient.new
    end
  end

  def get_json(path)
    response = Net::HTTP.get_response('m.cubecomps.com', "#{path}.json")
    JSON.parse response.body
  end

  class FakeTwitterClient
    def update(status, opts = {})
      puts "I'd post #{status.inspect} with opts #{opts.inspect} if this was running on production"
    end
  end
end
