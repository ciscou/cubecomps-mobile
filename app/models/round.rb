class Round
  attr_accessor :competition_id, :category_id, :id, :name

  def initialize(args)
    args.each do |k, v|
      send("#{k}=", v)
    end
  end

  def results
    @results ||= fetch_results
  end

  def to_param
    id.to_s
  end

  private

  def fetch_results
    doc = Nokogiri::HTML open "http://cubecomps.com/live.php?cid=#{competition_id}&cat=#{category_id}&rnd=#{id}"
    headers_table = doc.css("body > table > tr > td:last-child table.TH")
    headers = headers_table.css("tr th").map(&:text)
    results_table = doc.css("body > table > tr > td:last-child table.TD")
    results = results_table.css("tr").map do |result_tr|
      Result.new(
        position: result_tr.css("td:nth-child(1)").text,
        name:     result_tr.css("td:nth-child(2)").text,
        country:     result_tr.css("td:nth-child(3)").text,
        t1:       result_tr.css("td:nth-child(#{(headers.index("t1") || 999) + 1})").text,
        t2:       result_tr.css("td:nth-child(#{(headers.index("t2") || 999) + 1})").text,
        t3:       result_tr.css("td:nth-child(#{(headers.index("t3") || 999) + 1})").text,
        t4:       result_tr.css("td:nth-child(#{(headers.index("t4") || 999) + 1})").text,
        t5:       result_tr.css("td:nth-child(#{(headers.index("t5") || 999) + 1})").text,
        average:  result_tr.css("td:nth-child(#{(headers.index("average") || 999) + 1})").text,
        best:     result_tr.css("td:nth-child(#{(headers.index("best") || 999) + 1})").text
      )
    end
  end
end
