require 'spec_helper'

describe "Show competition" do
  before do
    FakeWeb.register_uri :get, "https://www.cubecomps.com/live.php?cid=3545&dnrd=1", [
      { response: File.read(Rails.root.join "spec", "fixtures", "cubecomps", "2018-09-19", "canarias-open.html") },
      { body: "Too Many Requests", status: [429, "Too Many Requests"] }
    ]
    FakeWeb.register_uri :get, "https://www.cubecomps.com/uploads/sch_3545.txt", [
      { response: File.read(Rails.root.join "spec", "fixtures", "cubecomps", "2018-09-19", "sch_3545.txt") },
      { body: "Too Many Requests", status: [429, "Too Many Requests"] }
    ]
  end

  let(:json) { JSON.parse(response.body) }

  it "should show competition's name" do
    get api_v2_competition_path(3545)

    expect(json["name"]).to eq "Canarias Open 2018"
  end

  it "should list competition's events" do
    get api_v2_competition_path(3545)

    expect(json["events"]).to include hash_including("code" => "333")
    expect(json["events"].first["rounds"]).to include hash_including("code" => "first")
  end

  it "should list competition's competitors" do
    get api_v2_competition_path(3545)

    expect(json["competitors"]).to include hash_including("name" => "Adrià García Fernández")
  end

  it "should show competition's schedule" do
    get api_v2_competition_path(3545)

    expect(json["schedule"].first["day"]).to eq "September 21, 2018"
    expect(json["schedule"].first["rows"]).to include hash_including("event_code"=>"333oh", "round_code"=>"cmbfinal")
  end
end
