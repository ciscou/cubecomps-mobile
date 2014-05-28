class Round
  attr_accessor :competition_id, :event_id, :id, :event_name, :name

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

  def competition_name
    @competition_name ||= fetch_competition_name
  end

  def event_name
    @event_name ||= fetch_event_name
  end

  def name
    @name ||= fetch_name
  end

  def started?
    [ competition_id, event_id, id ].all?(&:present?)
  end

  def results
    @results ||= fetch_results
  end

  def live?
    return false if past?
    return false unless updated_at

    (Time.parse(updated_at) + 15.minutes).future?
  end

  def best_record
    if $redis.sismember "world_records", redis_key
      "WR"
    elsif $redis.sismember "continental_records", redis_key
      "CR"
    elsif $redis.sismember "national_records", redis_key
      "NR"
    end
  end

  def finished?
    return true if past?

    updated_at && !live?
  end

  def past?
    $redis.sismember("past_competition_ids", competition_id)
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

  def fetch_competition_name
    text_nodes = doc.css("div.top").children.select do |node|
      node.is_a? Nokogiri::XML::Text
    end
    text_nodes.first.text
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

    if times_count > $redis.hget("times_count", redis_key).to_i
      $redis.hset("times_count", redis_key, times_count)
      $redis.hset("updated_at",  redis_key, Time.now)
    end
  end

  def check_records(results)
    return false if past?

    if results.any?(&:world_record?)
      $redis.sadd "world_records", redis_key
    else
      $redis.srem "world_records", redis_key
    end

    if results.any?(&:continental_record?)
      $redis.sadd "continental_records", redis_key
    else
      $redis.srem "continental_records", redis_key
    end

    if results.any?(&:national_record?)
      $redis.sadd "national_records", redis_key
    else
      $redis.srem "national_records", redis_key
    end
  end

  def updated_at
    @updated_at ||= $redis.hget("updated_at", redis_key)
  end

  def doc
    @doc ||= fetch_doc
  end

  def fetch_doc
    doc = Nokogiri::HTML open "http://cubecomps.com/live.php?cid=#{competition_id}&cat=#{event_id}&rnd=#{id}"
    raise NotFoundException if doc.css("body").text.include? "That competition is not available any more."

    doc
  end
end
