require 'spec_helper'

describe "List round results" do
  before do
    FakeWeb.register_uri :get, "https://cubecomps.com/live.php?cid=3545&dnrd=1", [
      { response: File.read(Rails.root.join "spec", "fixtures", "cubecomps", "2018-09-19", "canarias-open.html") }
    ]
    FakeWeb.register_uri :get, "https://cubecomps.com/uploads/sch_3545.txt", [
      { response: File.read(Rails.root.join "spec", "fixtures", "cubecomps", "2018-09-19", "sch_3545.txt") }
    ]
    FakeWeb.register_uri :get, "https://cubecomps.com/live.php?cid=3545&cat=1&rnd=1&dnrd=1", [
      { response: File.read(Rails.root.join "spec", "fixtures", "cubecomps", "2018-09-19", "canarias-open", "rubiks-cube", "first-round-not-complete.html") },
      { response: File.read(Rails.root.join "spec", "fixtures", "cubecomps", "2018-09-19", "canarias-open", "rubiks-cube", "first-round.html") }
    ]
  end

  after do
    Delorean.back_to_1985
  end

  def json
    JSON.parse(response.body)
  end

  def json_333
    json["events"].detect do |e|
      e["id"] == "1"
    end
  end

  def json_333_1
    json_333["rounds"].detect do |r|
      r["id"] == "1"
    end
  end

  it "should update live and finished labels" do
    get api_v2_competition_path(3545, 1, 1)
    expect(json_333["live"]    ).to be false
    expect(json_333["finished"]).to be false
    expect(json_333_1["live"]    ).to be false
    expect(json_333_1["finished"]).to be false

    get api_v2_competition_event_round_path(3545, 1, 1)

    get api_v2_competition_path(3545, 1, 1)
    expect(json_333["live"]    ).to be true
    expect(json_333["finished"]).to be false
    expect(json_333_1["live"]    ).to be true
    expect(json_333_1["finished"]).to be false

    Delorean.time_travel_to 13.minutes.from_now

    get api_v2_competition_path(3545, 1, 1)
    expect(json_333["live"]    ).to be true
    expect(json_333["finished"]).to be false
    expect(json_333_1["live"]    ).to be true
    expect(json_333_1["finished"]).to be false

    Delorean.time_travel_to 2.minutes.from_now

    get api_v2_competition_path(3545, 1, 1)
    expect(json_333["live"]    ).to be false
    expect(json_333["finished"]).to be false
    expect(json_333_1["live"]    ).to be false
    expect(json_333_1["finished"]).to be true
  end
end
