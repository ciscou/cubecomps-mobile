class Schedule
  CATEGORIES = {
    "333" => "Rubik's Cube",
    "222" => "2x2x2 Cube",
    "444" => "4x4x4 Cube",
    "555" => "5x5x5 Cube",
    "666" => "6x6x6 Cube",
    "777" => "7x7x7 Cube",
    "clock" => "Rubik's Clock",
    "magic" => "Magic",
    "mmagic" => "Master Magic",
    "minx"   => "Megaminx",
    "pyram"  => "Pyraminx",
    "sq1"    => "Square-1",
    "333oh"  => "3x3x3 One Handed",
    "333ft"  => "3x3x3 With Feet",
    "333fm"  => "3x3x3 Fewest Moves",
    "333bf"  => "3x3x3 Blindfolded",
    "444bf"  => "4x4x4 Blindfolded",
    "555bf"  => "4x4x4 Blindfolded",
    "333mbf" => "3x3x3 Multiple Blindfolded",
    "skewb"  => "Skewb",
    "reg"    => "REGISTRATION",
    "lun"    => "LUNCH",
    "tro"    => "AWARDS"
  }

  attr_accessor :start, :end, :category_code, :alternate_text, :round_name, :extra_info, :am_pm_format

  def initialize(args)
    args.each do |k, v|
      send("#{k}=", v)
    end
  end

  def self.parse(f)
    f.gets # ignore "01"
    f.gets # ignore tz abbreviation
    f.gets # ignore tz offset

    am_pm_format = f.gets.chomp

    date = nil

    f.read.lines.map do |s|
      s.chomp!

      if s.blank?
        nil
      elsif s =~ /\A[0-9]{8}\z/
        date = Time.new(s[0, 4].to_i, s[4, 2].to_i, s[6, 2].to_i)
        nil
      else
        parse_row(s, date, am_pm_format)
      end
    end.compact
  end

  def self.parse_row(s, date, am_pm_format)
    start_hour, end_hour,
    category_code,
    alternate_text,
    round_name,
    extra_info = s.split(",")

    new(
      start: date.change(hour: start_hour[0, 2].to_i, min: start_hour[2, 2].to_i, sec: start_hour[4, 2].to_i),
      end:   date.change(hour:   end_hour[0, 2].to_i, min:   end_hour[2, 2].to_i, sec:   end_hour[4, 2].to_i),
      category_code: category_code,
      alternate_text: alternate_text,
      round_name: round_name,
      extra_info: extra_info,
      am_pm_format: am_pm_format == "0"
    )
  end

  def formatted_start
    start.strftime(time_format)
  end

  def formatted_end
    self.end.strftime(time_format)
  end

  def time_format
    if am_pm_format
      "%I:%M"
    else
      "%H:%M"
    end
  end

  def category
    CATEGORIES.fetch(category_code) { category_code }
  end
end
