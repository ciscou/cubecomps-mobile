class Round
  attr_accessor :competition_id, :category_id, :id, :category_name, :name

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
      category_id:    round_params["cat"].first,
      id:             round_params["rnd"].first,
      name:           round_div.text
    )
  end

  def competition_name
    @competition_name ||= fetch_competition_name
  end

  def category_name
    @category_name ||= fetch_category_name
  end

  def name
    @name ||= fetch_name
  end

  def started?
    [ competition_id, category_id, id ].all? &:present?
  end

  def results
    @results ||= fetch_results
  end

  def t1?
    results.any? { |r| r.t1.present? }
  end

  def t2?
    results.any? { |r| r.t2.present? }
  end

  def t3?
    results.any? { |r| r.t3.present? }
  end

  def t4?
    results.any? { |r| r.t4.present? }
  end

  def t5?
    results.any? { |r| r.t5.present? }
  end

  def average?
    results.any? { |r| r.average.present? }
  end

  def mean?
    results.any? { |r| r.mean.present? }
  end

  def best?
    results.any? { |r| r.best.present? }
  end

  def to_param
    id.to_s
  end

  def cache_key
    ["rounds", competition_id, category_id, id].join("/")
  end

  private

  def fetch_competition_name
    text_nodes = doc.css("div.top").children.select do |node|
      node.is_a? Nokogiri::XML::Text
    end
    text_nodes.first.text
  end

  def fetch_category_and_round
    doc.css("div.main > div").text.split(" - ")
  end

  def fetch_category_name
    fetch_category_and_round.first
  end

  def fetch_name
    fetch_category_and_round.second
  end

  def fetch_results
    headers_table = doc.css("body > table > tr > td:last-child table.TH")
    results_table = doc.css("body > table > tr > td:last-child table.TD")
    results_table.css("tr").map do |result_tr|
      Result.build_from_headers_table_and_result_tr(headers_table, result_tr)
    end
  end

  def doc
    @doc ||= Nokogiri::HTML open "http://cubecomps.com/live.php?cid=#{competition_id}&cat=#{category_id}&rnd=#{id}"
  end
end
