class Result
  attr_accessor :position, :name, :country, :t1, :t2, :t3, :t4, :t5, :average, :average_record, :best, :best_record

  def initialize(args)
    args.each do |k, v|
      send("#{k}=", v)
    end
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
