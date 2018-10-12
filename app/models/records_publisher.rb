class RecordsPublisher
  def run
    competitions = get_json('/api/v2/competitions')
    competitions['in_progress'].each do |competition|
      handle_competition(competition)
    end
  rescue => e
    puts e.message
    puts e.backtrace
    ExceptionNotifier.notify_exception(e)
  end

  private

  def handle_competition(competition)
    events = get_json('/api/v2/competitions/%{competition_id}' % { competition_id: competition['id'] })["events"]
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
    return unless round['live']

    results = get_json('/api/v2/competitions/%{competition_id}/events/%{event_id}/rounds/%{round_id}' % { competition_id: competition['id'], event_id: round['event_id'], round_id: round['id'] })["results"]

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

    status = [description.truncate(140 - " ".length - "https://t.co/XwMi94X4tR".length), url].join(" ")
    tweet(status)
  end

  def tweet(status)
    twitter_client.update(status)
  rescue => e
    ExceptionNotifier.notify_exception(e, data: { status: status })
  end

  def publishable_event_name(event_name)
    {
      "3x3x3 Blindfolded"  => "3x3x3 Bld",
      "3x3x3 One-handed"   => "3x3x3 OH",
      "3x3x3 Fewest moves" => "3x3x3 FMC",
      "3x3x3 With Feet"    => "3x3x3 WF",
      "2x2x2 Cube"         => "2x2x2",
      "4x4x4 Cube"         => "4x4x4",
      "5x5x5 Cube"         => "5x5x5",
      "6x6x6 Cube"         => "6x6x6",
      "7x7x7 Cube"         => "7x7x7",
      "4x4x4 Blindfolded"  => "4x4x4 Bld",
      "5x5x5 Blindfolded"  => "5x5x5 Bld",
      "3x3x3 Multi-Blind"  => "3x3x3 Multi Bld",
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
    uri = URI("https://m.cubecomps.com#{path}")
    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      request = Net::HTTP::Get.new uri
      response = http.request request
      JSON.parse response.body
    end
  end

  class FakeTwitterClient
    def update(status, opts = {})
      puts "I'd post #{status.inspect} with opts #{opts.inspect} if this was running on production"
    end
  end
end
