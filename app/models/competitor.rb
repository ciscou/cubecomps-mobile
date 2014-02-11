class Competitor
  attr_accessor :id, :name

  def initialize(args)
    args.each do |k, v|
      send("#{k}=", v)
    end
  end

  def self.build_from_competitor_div(competitor_div)
    competitor_onclick = competitor_div.attr("onclick")
    competitor_url     = competitor_onclick.slice(17..-2)
    competitor_params  = CGI.parse competitor_url.split("?").last

    new(
      id:   competitor_params["compid"],
      name: competitor_div.text
    )
  end

  def to_param
    id.to_s
  end
end
