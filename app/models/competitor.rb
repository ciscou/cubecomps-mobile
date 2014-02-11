class Competitor
  attr_accessor :id, :name

  def initialize(args)
    args.each do |k, v|
      send("#{k}=", v)
    end
  end

  def self.build_from_competitor_div(competitor_div)
    new(
      id:   "omg",
      name: competitor_div.text
    )
  end

  def to_param
    id.to_s
  end
end
