class Competition
  attr_accessor :id, :name, :city, :date

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

    date = competition_tr.at_css("td div.p1 b").text
    city = competition_tr.at_css("td div.p2 b").text

    new(
      id:   id,
      name: link.text.strip,
      date: date,
      city: city
    )
  end

  def name
    @name ||= fetch_name
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

  def cache_key
    ["competitions", id].join("/")
  end

  def archive!
    if $redis.sadd "past_competition_ids", id
      puts "Archiving competition #{name} (#{id})"

      %w[updated_at times_count].each do |key|
        $redis.hkeys(key).select { |k| k.start_with? "#{id}:" }.each do |k|
          $redis.hdel key, k
        end
      end

      %w[published_average_records published_mean_records published_best_records].each do |key|
        $redis.smembers(key).select { |m| m.start_with? "#{id}:" }.each do |m|
          $redis.sdel(key, m)
        end
      end
    end
  end

  private

  def fetch_name
    text_nodes = doc.css("div.top").children.select do |node|
      node.is_a? Nokogiri::XML::Text
    end
    text_nodes.first.text.strip
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
    @sch ||= begin
               f = open("http://cubecomps.com/uploads/sch_#{id}.txt", redirect: false)
               ScheduleParser.new(f).parse
             rescue OpenURI::HTTPError
               []
             end
  end

  def doc
    @doc ||= fetch_doc
  end

  def fetch_doc
    doc = Nokogiri::HTML open "http://cubecomps.com/live.php?cid=#{id}&dnrd=1"
    raise NotFoundException if doc.css("body").text.include? "That competition is not available any more."

    doc
  end
end
