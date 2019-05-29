class Competition
  attr_accessor :id, :name, :city, :country, :country_code, :date

  def initialize(args)
    args.each do |k, v|
      send("#{k}=", v)
    end
  end

  def self.find(id)
    new(id: id)
  end

  def self.build_from_competition_tr(competition_tr)
    link = competition_tr.at_css("td div.p0 b a")
    competition_url = link.attr("href")
    competition_params = CGI.parse competition_url.split("?").last
    id = competition_params["cid"].first
    return nil unless id.present?

    img = link.at_css("img.flag")
    country_code = if img
                      flag = img.attr("src")
                      country_code = flag.split("/").last.split(".").first
                   else
                     "xx"
                   end

    date = competition_tr.at_css("td div.p1 b").text
    city, country = competition_tr.at_css("td div.p2 b").text.split(" - ")

    new(
      id:   id,
      name: link.text.strip,
      date: date,
      city: city,
      country: country,
      country_code: country_code
    )
  end

  def name
    @name ||= fetch_name
  end

  def city
    @city ||= fetch_city
  end

  def country
    @country ||= fetch_country
  end

  def events
    @events ||= fetch_events
  end

  def competitors
    @competitors ||= fetch_competitors
  end

  def schedule
    @schedule ||= fetch_schedule
  end

  def to_param
    id.to_s
  end

  def records_cache
    @records_cache ||= {
      "world_records"       => fetch_records_cache("world_records"),
      "continental_records" => fetch_records_cache("continental_records"),
      "national_records"    => fetch_records_cache("national_records")
    }
  end

  def updated_at_cache
    @updated_at_cache ||= fetch_updated_at_cache
  end

  def past?
    return @past if defined?(@past)
    @past = $redis.sismember("past_competition_ids", id)
  rescue Redis::CannotConnectError => e
    ExceptionNotifier.notify_exception(e)

    false
  end

  def cache_key
    ["competitions", id].join("/")
  end

  def archive!
    if $redis.sadd "past_competition_ids", id
      puts "Archiving competition #{name} (#{id})"

      $redis.del("updated_at:#{id}")
      $redis.del("times_count:#{id}")

      %w[published_average_records published_mean_records published_best_records].each do |key|
        $redis.smembers(key).select { |m| m.start_with? "#{id}:" }.each do |m|
          $redis.srem(key, m)
        end
      end
    end
  end

  private

  def fetch_records_cache(records_key)
    $redis.smembers("#{records_key}:#{id}")
  rescue Redis::CannotConnectError => e
    ExceptionNotifier.notify_exception(e)

    []
  end

  def fetch_updated_at_cache
    $redis.hgetall("updated_at:#{id}")
  rescue Redis::CannotConnectError => e
    ExceptionNotifier.notify_exception(e)

    {}
  end

  def fetch_name_city_and_country
    text_nodes = doc.css("div.top").children.select do |node|
      node.is_a? Nokogiri::XML::Text
    end
    text_nodes.map(&:text).map(&:strip)
  end

  def fetch_name
    fetch_name_city_and_country.first
  end

  def fetch_city
    fetch_name_city_and_country.second
  end

  def fetch_country
    fetch_name_city_and_country.third
  end

  def fetch_events
    events_table = doc.css("body > table > tr > td:first-child table")
    events = events_table.css("tr td").map do |event_td|
      Event.build_from_event_td(event_td)
    end
    events.compact
  end

  def fetch_competitors
    competitors_container = doc.css(".collapser_c")
    competitors_container.css("div.round").map do |competitor_div|
      Competitor.build_from_competitor_div(competitor_div)
    end
  end

  def fetch_schedule
    []
  end

  def doc
    @doc ||= fetch_doc
  end

  def fetch_doc
    doc = Nokogiri::HTML get_html "/live.php?cid=#{id}&dnrd=1"
    raise NotFoundException if doc.css("body").text.include? "That competition is not available any more."

    doc
  end

  def get_html(path)
    uri = URI("https://www.cubecomps.com#{path}")
    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      request = Net::HTTP::Get.new uri
      response = http.request request
      response.body
    end
  end
end
