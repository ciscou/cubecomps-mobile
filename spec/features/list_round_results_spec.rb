require 'spec_helper'

feature "List round results" do
  before do
    FakeWeb.register_uri :get, "http://cubecomps.com/", response: File.read(Rails.root.join "spec", "fixtures", "cubecomps", "2014-02-28", "home.html")
    FakeWeb.register_uri :get, "http://cubecomps.com/live.php?cid=418", response: File.read(Rails.root.join "spec", "fixtures", "cubecomps", "2014-02-28", "delhi-open.html")
    FakeWeb.register_uri :get, "http://cubecomps.com/live.php?cid=418&cat=1&rnd=1", response: File.read(Rails.root.join "spec", "fixtures", "cubecomps", "2014-02-28", "delhi-open", "rubiks-cube", "combined-first.html")

    visit root_path
    click_link "Delhi Open"
    find("#event-1").click_link "Combined First"
  end

  it "should list round results" do
    within("table#results tbody tr:nth-child(1)") do
      expect(page).to have_css "td.top-position:nth-child(1)", text: "1"
      expect(page).to have_css "td:nth-child(2)",  text: "Akash Rupela"
      expect(page).to have_css "td:nth-child(3)",  text: "India"
      expect(page).to have_css "td:nth-child(4)",  text:   "10.34"
      expect(page).to have_css "td:nth-child(5)",  text:    "9.75"
      expect(page).to have_css "td:nth-child(6)",  text:   "13.31"
      expect(page).to have_css "td:nth-child(7)",  text:    "8.29"
      expect(page).to have_css "td:nth-child(8)",  text:   "11.34"
      expect(page).to have_css "td:nth-child(9)",  text:   "10.48"
      expect(page).to have_css "td:nth-child(10)", text: "NR 8.29"
    end
  end
end
