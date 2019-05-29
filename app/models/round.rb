class Round
  CODE_TO_NAME = {
    "cmbfirst"  => "Combined First",
    "first"     => "First Round",
    "second"    => "Second Round",
    "semifinal" => "Semi Final",
    "cmbfinal"  => "Combined Final",
    "final"     => "Final"
  }

  NAME_TO_CODE = CODE_TO_NAME.invert

  attr_accessor :competition_id, :event_id, :id, :event_name, :name, :past_cache, :updated_at_cache, :best_record_cache

  def initialize(args)
    args.each do |k, v|
      send("#{k}=", v)
    end
  end

  def self.build_from_round_div(round_div)
    round_onclick = round_div.attr("onclick")
    round_params = if round_onclick.nil?
                     Hash.new { [] }
                   else
                     round_url = round_onclick.slice(17..-2)
                     CGI.parse round_url.split("?").last
                   end
    new(
      competition_id: round_params["cid"].first,
      event_id:       round_params["cat"].first,
      id:             round_params["rnd"].first,
      name:           round_div.text
    )
  end

  def code
    NAME_TO_CODE[name]
  end

  def event_code
    Event::CODE_TO_NAME.keys[event_id.to_i - 1]
  end

  def competition_name
    @competition_name ||= fetch_competition_name
  end

  def competition_city
    @competition_city ||= fetch_competition_city
  end

  def competition_country
    @competition_country ||= fetch_competition_country
  end

  def event_name
    @event_name ||= fetch_event_name
  end

  def name
    @name ||= fetch_name
  end

  def setup?
    [ competition_id, event_id, id ].all?(&:present?)
  end

  def results
    @results ||= fetch_results
  end

  def best_record
    if fetch_best_record("world_records")
      "WR"
    elsif fetch_best_record("continental_records")
      "CR"
    elsif fetch_best_record("national_records")
      "NR"
    end
  end

  def live?
    return false if past?
    return false unless updated_at

    (Time.parse(updated_at) + 15.minutes).future?
  end

  def started?
    return true if past?

    !! updated_at
  end

  def finished?
    return true if past?

    finished = updated_at && !live?
    !!finished
  end

  def past?
    return @past if defined?(@past)
    @past = fetch_past
  rescue Redis::CannotConnectError => e
    ExceptionNotifier.notify_exception(e)

    false
  end

  def fetch_past
    if @past_cache.nil?
      $redis.sismember("past_competition_ids", competition_id)
    else
      @past_cache
    end
  rescue Redis::CannotConnectError => e
    ExceptionNotifier.notify_exception(e)

    false
  end

  def to_param
    id.to_s
  end

  def cache_key
    ["rounds", competition_id, event_id, id].join("/")
  end

  def redis_key
    [competition_id, event_id, id].join(":")
  end

  private

  def fetch_best_record(records_key)
    if @best_record_cache.nil?
      $redis.sismember "#{records_key}:#{competition_id}", redis_key
    else
      @best_record_cache[records_key].include?(redis_key)
    end
  rescue Redis::CannotConnectError => e
    ExceptionNotifier.notify_exception(e)

    false
  end

  def fetch_competition_name_city_and_country
    text_nodes = doc.css("div.top").children.select do |node|
      node.is_a? Nokogiri::XML::Text
    end
    text_nodes.map(&:text).map(&:strip)
  end

  def fetch_competition_name
    fetch_competition_name_city_and_country.first
  end

  def fetch_competition_city
    fetch_competition_name_city_and_country.second
  end

  def fetch_competition_country
    fetch_competition_name_city_and_country.third
  end

  def fetch_event_and_round
    doc.css("div.main > div").text.split(" - ")
  end

  def fetch_event_name
    fetch_event_and_round.first
  end

  def fetch_name
    fetch_event_and_round.second
  end

  def fetch_results
    headers_table = doc.css("body > table > tr > td:last-child table.TH")
    results_table = doc.css("body > table > tr > td:last-child table.TD")
    results = results_table.css("tr").map do |result_tr|
      Result.build_from_headers_table_and_result_tr(headers_table, result_tr)
    end
    check_live_results(results)
    check_records(results)
    Results.new(results)
  end

  def check_live_results(results)
    return false if past?

    times_count = results.flat_map do |r|
      [r.t1, r.t2, r.t3, r.t4, r.t5]
    end.count(&:present?)

    if times_count > $redis.hget("times_count:#{competition_id}", redis_key).to_i
      $redis.hset("times_count:#{competition_id}", redis_key, times_count)
      $redis.hset("updated_at:#{competition_id}", redis_key, Time.now)
    end
  rescue Redis::CannotConnectError => e
    ExceptionNotifier.notify_exception(e)
  end

  def check_records(results)
    return false if past?

    if results.any?(&:world_record?)
      $redis.sadd "world_records:#{competition_id}", redis_key
    else
      $redis.srem "world_records:#{competition_id}", redis_key
    end

    if results.any?(&:continental_record?)
      $redis.sadd "continental_records:#{competition_id}", redis_key
    else
      $redis.srem "continental_records:#{competition_id}", redis_key
    end

    if results.any?(&:national_record?)
      $redis.sadd "national_records:#{competition_id}", redis_key
    else
      $redis.srem "national_records:#{competition_id}", redis_key
    end
  rescue Redis::CannotConnectError => e
    ExceptionNotifier.notify_exception(e)
  end

  def updated_at
    @updated_at ||= fetch_updated_at
  rescue Redis::CannotConnectError => e
    ExceptionNotifier.notify_exception(e)

    nil
  end

  def fetch_updated_at
    if @updated_at_cache.nil?
      $redis.hget("updated_at:#{competition_id}", redis_key)
    else
      @updated_at_cache[redis_key]
    end
  rescue Redis::CannotConnectError => e
    ExceptionNotifier.notify_exception(e)

    false
  end

  def doc
    @doc ||= fetch_doc
  end

  def fetch_doc
    doc = Nokogiri::HTML get_html "/live.php?cid=#{competition_id}&cat=#{event_id}&rnd=#{id}&dnrd=1"
    raise NotFoundException if doc.css("body").text.include? "That competition is not available any more."

    doc
  end

  def get_html(path)
    uri = URI("https://www.cubecomps.com#{path}")
    Net::HTTP.start(uri.host, uri.port, use_ssl: true, ssl_version: :SSLv23) do |http|
      request = Net::HTTP::Get.new uri
      response = http.request request
      response.body
    end
  end
end
