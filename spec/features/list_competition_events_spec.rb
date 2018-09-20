require 'spec_helper'

feature "List competition events" do
  before do
    FakeWeb.register_uri :get, "http://cubecomps.com/", [
      { response: File.read(Rails.root.join "spec", "fixtures", "cubecomps", "2018-09-19", "home.html") },
      { body: "Too Many Requests", status: [429, "Too Many Requests"] }
    ]
    FakeWeb.register_uri :get, "http://cubecomps.com/live.php?cid=3545&dnrd=1", [
      { response: File.read(Rails.root.join "spec", "fixtures", "cubecomps", "2018-09-19", "canarias-open.html") },
      { body: "Too Many Requests", status: [429, "Too Many Requests"] }
    ]
    FakeWeb.register_uri :get, "http://cubecomps.com/uploads/sch_3545.txt", [
      { response: File.read(Rails.root.join "spec", "fixtures", "cubecomps", "2018-09-19", "sch_3545.txt") },
      { body: "Too Many Requests", status: [429, "Too Many Requests"] }
    ]

    visit root_path
    click_link "Canarias Open"
  end

  it "should list competition events", js: true do
    [
      "3x3x3 Cube",
      "4x4x4 Cube",
      "5x5x5 Cube",
      "2x2x2 Cube",
      "3x3x3 Blindfolded",
      "3x3x3 One-Handed",
      "Megaminx",
      "Pyraminx",
      "Clock",
      "Skewb"
    ].each do |event_name|
      expect(page).to have_css("h2", text: event_name)
    end

    click_link "3x3x3 Cube"
    expect(page).to have_link "First Round"
    expect(page).to have_link "Second Round"
    expect(page).to have_link "Final"
  end
end
