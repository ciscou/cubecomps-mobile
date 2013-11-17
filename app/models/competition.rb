class Competition
  attr_accessor :id, :name

  def initialize(args)
    args.each do |k, v|
      send("#{k}=", v)
    end
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

  def self.find(id)
    new(id: id)
  end

  def fetch_categories
    doc = Nokogiri::HTML open "http://cubecomps.com/live.php?cid=#{id}"
    categories_table = doc.css("body > table > tr > td:first-child table")
    categories = categories_table.css("tr td").each_with_object([]) do |competition_td, a|
      competition_name = competition_td.css("div.event").text
      unless ["", "Competitors"].include? competition_name
        competition_rounds = competition_td.css("div.round").map do |round_div|
          round_url = round_div.attr("onclick").slice(17..-2)
          round_params = CGI.parse round_url.split("?").last
          Round.new(
            competition_id: round_params["cid"].first,
            category_id:    round_params["cat"].first,
            id:             round_params["rnd"].first,
            name:           round_div.text
          )
        end
        a << Category.new(
          id:     competition_rounds.first.category_id,
          name:   competition_name,
          rounds: competition_rounds
        )
      end
    end
  end
end
