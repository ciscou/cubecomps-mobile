require 'spec_helper'

describe "Show competitor" do
  before do
    FakeWeb.register_uri :get, "https://www.cubecomps.com/live.php?cid=3545&compid=16&dnrd=1", [
      { response: File.read(Rails.root.join "spec", "fixtures", "cubecomps", "2018-09-19", "canarias-open", "competitors", "daniel-gracia.html") },
      { body: "Too Many Requests", status: [429, "Too Many Requests"] }
    ]
  end

  let(:json) { JSON.parse(response.body) }

  it "should show competition's name" do
    get api_v1_competition_competitor_path(3545, 16)

    expect(json["competition_name"]).to eq "Canarias Open 2018"
  end

  it "should show competitor's name" do
    get api_v1_competition_competitor_path(3545, 16)

    expect(json["name"]).to eq "Daniel Gracia Ortiz"
  end

  it "should list competitor's resuls" do
    get api_v1_competition_competitor_path(3545, 16)

    expect(json["results"]["3x3x3 Cube"]).to include hash_including("position"=>"2", "top_position"=>true, "event"=>"3x3x3 Cube", "round"=>"First Round")
  end
end
