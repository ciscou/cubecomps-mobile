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
    competitions.shift(10)
    competitions.count(&:archive!)
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

    competitions_tr = doc.css("div.list")[index].css("table tr")
    competition_divs = competitions_tr.css("td div.p0")
    competition_divs = competitions_tr.css("td div") if competition_divs.empty?
    competition_divs.map do |competition_div|
      Competition.build_from_competition_div(competition_div)
    end.compact
  end

  def fetch_competitions_headers
    doc.css("div.header").map(&:text)
  end

  def doc
    @doc ||= Nokogiri::HTML open "http://cubecomps.com/#{"?all=1" if @all}"
  end
end
