require 'spec_helper'

feature "List competition events" do
  before do
    FakeWeb.register_uri :get, "http://cubecomps.com/", response: File.read(Rails.root.join "spec", "fixtures", "cubecomps", "2014-02-28", "home.html")
    FakeWeb.register_uri :get, "http://cubecomps.com/live.php?cid=418&dnrd=1", response: File.read(Rails.root.join "spec", "fixtures", "cubecomps", "2014-02-28", "delhi-open.html")

    visit root_path
    click_link "Delhi Open"
  end

  it "should list competition events" do
    [
      "Rubik's Cube",
      "4x4x4 Cube",
      "5x5x5 Cube",
      "2x2x2 Cube",
      "Rubik's Cube: Blindfolded",
      "Rubik's Cube: One-handed",
      "Rubik's Cube: Fewest moves",
      "Megaminx",
      "Pyraminx",
      "Clock",
      "Skewb",
      "4x4x4 Cube: Blindfolded"
    ].each do |event_name|
      expect(page).to have_css("h2", text: event_name)
    end

    within("#event-1") do
      expect(page).to have_link "Combined First"
      expect(page).to have_css "em.muted", text: "Second Round"
      expect(page).to have_css "em.muted", text: "Final"
    end
  end
end
