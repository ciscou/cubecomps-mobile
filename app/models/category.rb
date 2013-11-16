class Category
  attr_accessor :id, :name, :rounds

  def initialize(args)
    args.each do |k, v|
      send("#{k}=", v)
    end
  end

  def to_param
    id.to_s
  end
end
