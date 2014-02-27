module RecordsHelper
  def format_record(record)
    content_tag :span, record,
      class: "record #{record.downcase}",
      title: humanize_record(record)
  end

  def humanize_record(record)
    {
      "PB" => "Personal Best",
      "NR" => "National Record",
      "CR" => "Continental Record",
      "WR" => "World Record"
    }.fetch(record, "")
  end
end
