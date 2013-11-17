class Competitions
  def in_progress
    @in_progress ||= fetch_in_progress
  end

  def cache_key
    "competitions"
  end

  private

  def fetch_in_progress
    doc = Nokogiri::HTML open "http://cubecomps.com/"
    in_progress_competitions_tr = doc.css("div.list").first.css("table tr")
    in_progress_competitions = in_progress_competitions_tr.css("td div").map do |competition_div|
      competition_url = competition_div.css("b.p a").attr("href").value
      competition_params = CGI.parse competition_url.split("?").last
      Competition.new(
        id:   competition_params["cid"].first,
        name: competition_div.css("b.p a").text.strip
      )
    end
  end
end
