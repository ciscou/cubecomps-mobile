class Round
  attr_accessor :competition_id, :category_id, :id, :name

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

  def started?
    [ competition_id, category_id, id ].all? &:present?
  end

  def results
    @results ||= fetch_results
  end

  def to_param
    id.to_s
  end

  def cache_key
    ["rounds", competition_id, category_id, id].join("/")
  end

  private

  def fetch_results
    doc = Nokogiri::HTML open "http://cubecomps.com/live.php?cid=#{competition_id}&cat=#{category_id}&rnd=#{id}"
    headers_table = doc.css("body > table > tr > td:last-child table.TH")
    results_table = doc.css("body > table > tr > td:last-child table.TD")
    results_table.css("tr").map do |result_tr|
      Result.build_from_headers_table_and_result_tr(headers_table, result_tr)
    end
  end
end
