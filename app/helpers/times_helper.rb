module TimesHelper
  def format_time(time)
    return time if time.nil?

    # removing leading and trailing &nbsp;
    time.gsub(/\A[[:space:]]/, "").gsub(/[[:space:]]\z/, "")
  end
end
