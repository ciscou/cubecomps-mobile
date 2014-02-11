class Result
  attr_accessor :position, :name, :country, :cat_rnd, :t1, :t2, :t3, :t4, :t5, :average, :average_record, :mean, :mean_record, :best, :best_record
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
      cat_rnd:  result_tr.css("td:nth-child(2)").text,
      t1:       extract_from_headers_and_tr(headers, result_tr, "t1"),
      t2:       extract_from_headers_and_tr(headers, result_tr, "t2"),
      t3:       extract_from_headers_and_tr(headers, result_tr, "t3"),
      t4:       extract_from_headers_and_tr(headers, result_tr, "t4"),
      t5:       extract_from_headers_and_tr(headers, result_tr, "t5"),
      average:  extract_from_headers_and_tr(headers, result_tr, "average"),
      mean:     extract_from_headers_and_tr(headers, result_tr, "mean"),
      best:     extract_from_headers_and_tr(headers, result_tr, "best")
    )
  end

  def self.extract_from_headers_and_tr(headers, tr, col)
    if index = headers.index(col)
      tr.css("td:nth-child(#{index + 1})").text
    end
  end

  def category
    cat_rnd.split(" - ").first
  end

  def round
    cat_rnd.split(" - ").second
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

  private

  def extract_record_from!(s)
    return unless s.present?

    s.gsub!(/^\u00A0(WR|CR|NR|PB)\u00A0/, "")
    $1
  end
end
