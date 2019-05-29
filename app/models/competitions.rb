class Competitions
  def initialize(all: false)
    @all = all
  end

  def in_progress
    @in_progress ||= fetch_in_progress
  end

  def past
    @past ||= fetch_past
  end

  def upcoming
    @upcoming ||= fetch_upcoming
  end

  def cache_key
    "competitions"
  end

  def archive_old!
    competitions = past
    competitions.shift(50)
    competitions.count(&:archive!)
  rescue => e
    ExceptionNotifier.notify_exception(e)
  end

  private

  def fetch_in_progress
    fetch_competitions_at fetch_competitions_headers.index("Competitions in progress")
  end

  def fetch_past
    fetch_competitions_at fetch_competitions_headers.index("Past competitions")
  end

  def fetch_upcoming
    fetch_competitions_at fetch_competitions_headers.index("Upcoming competitions")
  end

  def fetch_competitions_at(index)
    return [] unless index

    competitions_trs = doc.css("div.list")[index].css("table tr")
    competitions_trs.map do |competition_tr|
      Competition.build_from_competition_tr(competition_tr)
    end
  end

  def fetch_competitions_headers
    doc.css("div.header").map(&:text)
  end

  def doc
    @doc ||= Nokogiri::HTML get_html "/#{"?all=1" if @all}"
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
