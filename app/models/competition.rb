class Competition
  attr_accessor :id, :name

  def initialize(args)
    args.each do |k, v|
      send("#{k}=", v)
    end
  end

  def self.find(id)
    new(id: id)
  end

  def self.build_from_competition_div(competition_div)
    competition_url = competition_div.css("b.p a").attr("href").value
    competition_params = CGI.parse competition_url.split("?").last
    new(
      id:   competition_params["cid"].first,
      name: competition_div.css("b.p a").text.strip
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

  private

  def fetch_name
    text_nodes = doc.css("div.top").children.select do |node|
      node.is_a? Nokogiri::XML::Text
    end
    text_nodes.first.text
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
               Schedule.parse(f)
             rescue OpenURI::HTTPError
               []
             end
  end

  def doc
    @doc ||= Nokogiri::HTML open "http://cubecomps.com/live.php?cid=#{id}"
  end
end
