class Results
  include Enumerable

  def initialize(results)
    @results = results
  end

  %w[t1 t2 t3 t4 t5 mean average best].each do |m|
    define_method "#{m}?" do
      @results.any?(&m.to_sym)
    end
  end

  def by_category
    h = group_by(&:category)
    h.merge(h) { |k, v| self.class.new(v) }
  end

  def each(&block)
    @results.each(&block)
  end

  def empty?
    @results.empty?
  end
end
