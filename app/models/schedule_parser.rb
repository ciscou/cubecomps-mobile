class ScheduleParser
  def initialize(f)
    @file = f
    @rounds = Hash.new(0)
  end

  def parse
    return [] unless @file.gets.chomp == "01"

    @file.gets # ignore tz abbreviation
    @file.gets # ignore tz offset

    am_pm_format = @file.gets.chomp

    date = Time.at(0)

    @file.read.lines.map do |s|
      s.chomp!

      if s.blank?
        nil
      elsif s.strip =~ /\A[0-9]{8}\z/
        s.strip!
        date = Time.new(s[0, 4].to_i, s[4, 2].to_i, s[6, 2].to_i)
        nil
      else
        parse_row(s, date, am_pm_format)
      end
    end.compact
  end

  private

  def parse_row(s, date, am_pm_format)
    start_hour, end_hour,
    event_code,
    alternate_text,
    round_name,
    extra_info = s.split(",")

    return nil unless start_hour && end_hour

    Schedule.new(
      start: date.change(hour: start_hour[0, 2].to_i, min: start_hour[2, 2].to_i, sec: start_hour[4, 2].to_i),
      end:   date.change(hour:   end_hour[0, 2].to_i, min:   end_hour[2, 2].to_i, sec:   end_hour[4, 2].to_i),
      event_code: event_code,
      alternate_text: alternate_text,
      round_id: next_round_for(event_code),
      round_name: round_name,
      extra_info: extra_info,
      am_pm_format: am_pm_format == "0"
    )
  end

  def next_round_for(event_code)
    @rounds[event_code] += 1
  end
end
