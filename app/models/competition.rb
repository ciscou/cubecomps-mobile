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

  def categories
    @categories ||= fetch_categories
  end

  def to_param
    id.to_s
  end

  def cache_key
    ["competitions", id].join("/")
  end

  private

  def fetch_categories
    doc = Nokogiri::HTML open "http://cubecomps.com/live.php?cid=#{id}"
    categories_table = doc.css("body > table > tr > td:first-child table")
    categories = categories_table.css("tr td").map do |category_td|
      Category.build_from_category_td(category_td)
    end
    categories.compact
  end
end
