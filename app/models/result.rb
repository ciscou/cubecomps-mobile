class Result
  attr_accessor :position, :top_position, :competitor_id, :competition_id, :event_id, :round_id, :name, :country, :evt_rnd, :t1, :t2, :t3, :t4, :t5, :average, :average_record, :mean, :mean_record, :best, :best_record
  alias_method :top_position?, :top_position
  %w[t1 t2 t3 t4 t5 mean average best].each do |m|
    alias_method "#{m}?", m
  end

  def initialize(args)
    args.each do |k, v|
      send("#{k}=", v)
    end
  end

  def self.build_from_headers_table_and_result_tr(headers_table, result_tr)
    headers = headers_table.css("tr th").map(&:text)
    new(
      position: result_tr.css("td:nth-child(1)").text,
      name:     result_tr.css("td:nth-child(2)").text,
      country:  result_tr.css("td:nth-child(3)").text,
      evt_rnd:  result_tr.css("td:nth-child(2)").text,
      t1:       extract_from_headers_and_tr(headers, result_tr, "t1"),
      t2:       extract_from_headers_and_tr(headers, result_tr, "t2"),
      t3:       extract_from_headers_and_tr(headers, result_tr, "t3"),
      t4:       extract_from_headers_and_tr(headers, result_tr, "t4"),
      t5:       extract_from_headers_and_tr(headers, result_tr, "t5"),
      average:  extract_from_headers_and_tr(headers, result_tr, "average"),
      mean:     extract_from_headers_and_tr(headers, result_tr, "mean"),
      best:     extract_from_headers_and_tr(headers, result_tr, "best")
    ).tap do |result|
      position_td_style = result_tr.css("td:nth-child(1)").attr("style").try(:value) || ""
      result.top_position = position_td_style.include?("background-color:#CCFF00")

      competitor_link = result_tr.css("td:nth-child(2) a")
      competitor_link_attrs = CGI.parse competitor_link.attr("href").to_s.split("?").last
      result.competitor_id = competitor_link_attrs["compid"].first
      result.competition_id = competitor_link_attrs["cid"].first
      result.event_id = competitor_link_attrs["cat"].first
      result.round_id = competitor_link_attrs["rnd"].first
    end
  end

  def self.extract_from_headers_and_tr(headers, tr, col)
    if index = headers.index(col)
      tr.css("td:nth-child(#{index + 1})").text
    end
  end

  def event
    evt_rnd.split(" - ").first
  end

  def round
    evt_rnd.split(" - ").second
  end

  def average=(s)
    @average = s
    @average_record = extract_record_from! @average
  end

  def mean=(s)
    @mean = s
    @mean_record = extract_record_from! @mean
  end

  def best=(s)
    @best = s
    @best_record = extract_record_from! @best
  end

  def world_record?
    "WR".in? [best_record, mean_record, average_record]
  end

  def continental_record?
    "CR".in? [best_record, mean_record, average_record]
  end

  def national_record?
    "NR".in? [best_record, mean_record, average_record]
  end

  private

  def extract_record_from!(s)
    return unless s.present?

    s.gsub!(/^\u00A0(WR|CR|NR|PB)\u00A0/, "")
    $1
  end
end
