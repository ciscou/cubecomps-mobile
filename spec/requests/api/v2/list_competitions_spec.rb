require 'spec_helper'

describe "List competitions" do
  before do
    FakeWeb.register_uri :get, "https://cubecomps.com/", [
      { response: File.read(Rails.root.join "spec", "fixtures", "cubecomps", "2018-09-19", "home.html") },
      { body: "Too Many Requests", status: [429, "Too Many Requests"] }
    ]
  end

  let(:json) { JSON.parse(response.body) }

  it "should list competitions in progress" do
    get api_v2_competitions_path

    expect(json["in_progress"]).to be_empty
  end

  it "should list past competitions" do
    get api_v2_competitions_path

    [
      "Cube Factory Częstochowa",
      "KSF Semey City",
      "Canarias Open",
      # ...
      "Hillsboro Open"
    ].each do |competition_name|
      expect(json["past"]).to include hash_including("name" => competition_name)
    end
  end

  it "should list upcoming competitions" do
    get api_v2_competitions_path

    [
      "Villa Open",
      "Swiss Nationals",
      "Belgorod Open",
      # ...
      "Manchester Open"
    ].each do |competition_name|
      expect(json["upcoming"]).to include hash_including("name" => competition_name)
    end
  end
end
