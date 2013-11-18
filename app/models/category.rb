class Category
  attr_accessor :id, :name, :rounds

  def initialize(args)
    args.each do |k, v|
      send("#{k}=", v)
    end
  end

  def self.build_from_category_td(category_td)
    category_name = category_td.css("div.event, div.c_event").text
    unless ["", "Competitors", "Schedule"].include? category_name
      category_rounds = category_td.css("div.round, div.c_round").map do |round_div|
        Round.build_from_round_div(round_div)
      end
      new(
        id:     category_rounds.first.category_id,
        name:   category_name,
        rounds: category_rounds
      )
    end
  end

  def to_param
    id.to_s
  end
end
