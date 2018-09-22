module TimesHelper
  def format_time(time)
    # removing leading and trailing &nbsp;
    time.gsub(/\A[[:space:]]/, "").gsub(/[[:space:]]\z/, "")
  end
end
