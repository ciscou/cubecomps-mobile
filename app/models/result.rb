class Result
  attr_accessor :position, :name, :country, :t1, :t2, :t3, :t4, :t5, :average, :average_record, :best, :best_record

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
      t1:       result_tr.css("td:nth-child(#{(headers.index("t1") || 999) + 1})").text,
      t2:       result_tr.css("td:nth-child(#{(headers.index("t2") || 999) + 1})").text,
      t3:       result_tr.css("td:nth-child(#{(headers.index("t3") || 999) + 1})").text,
      t4:       result_tr.css("td:nth-child(#{(headers.index("t4") || 999) + 1})").text,
      t5:       result_tr.css("td:nth-child(#{(headers.index("t5") || 999) + 1})").text,
      average:  result_tr.css("td:nth-child(#{(headers.index("average") || 999) + 1})").text,
      best:     result_tr.css("td:nth-child(#{(headers.index("best") || 999) + 1})").text
    )
  end

  def average=(s)
    @average = s
    @average_record = extract_record_from! @average
  end

  def best=(s)
    @best = s
    @best_record = extract_record_from! @best
  end

  private

  def extract_record_from!(s)
    s.gsub!(/^\u00A0(WR|CR|NR)\u00A0/, "")
    $1
  end
end
