require 'spec_helper'

feature "List round results" do
  before do
    FakeWeb.register_uri :get, "http://cubecomps.com/", response: File.read(Rails.root.join "spec", "fixtures", "cubecomps", "2018-09-19", "home.html")
    FakeWeb.register_uri :get, "http://cubecomps.com/live.php?cid=3545&dnrd=1", response: File.read(Rails.root.join "spec", "fixtures", "cubecomps", "2018-09-19", "canarias-open.html")
    FakeWeb.register_uri :get, "http://cubecomps.com/live.php?cid=3545&cat=1&rnd=1&dnrd=1", response: File.read(Rails.root.join "spec", "fixtures", "cubecomps", "2018-09-19", "canarias-open", "rubiks-cube", "first-round.html")

    visit root_path
    click_link "Canarias Open"
    click_link "3x3x3 Cube"
    click_link "First Round"
  end

  it "should list round results", js: true do
    within("table#results tbody tr:nth-child(1)") do
      expect(page).to have_css "td.top-position:nth-child(1)", text: "1"
      expect(page).to have_css "td:nth-child(2)",  text: "Sergi Sabat"
      expect(page).to have_css "td:nth-child(3)",  text: "Spain"
      expect(page).to have_css "td:nth-child(4)",  text: "8.19"
      expect(page).to have_css "td:nth-child(5)",  text: "9.37"
      expect(page).to have_css "td:nth-child(6)",  text: "11.14"
      expect(page).to have_css "td:nth-child(7)",  text: "11.74"
      expect(page).to have_css "td:nth-child(8)",  text: "9.82"
      expect(page).to have_css "td:nth-child(9)",  text: "10.11"
      expect(page).to have_css "td:nth-child(10)", text: "8.19"
    end
  end
end
