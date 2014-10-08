require 'spec_helper'

feature "Live results" do
  before do
    FakeWeb.register_uri :get, "http://cubecomps.com/", response: File.read(Rails.root.join "spec", "fixtures", "cubecomps", "2014-02-28", "home.html")
    FakeWeb.register_uri :get, "http://cubecomps.com/live.php?cid=418&dnrd=1", response: File.read(Rails.root.join "spec", "fixtures", "cubecomps", "2014-02-28", "delhi-open.html")
    FakeWeb.register_uri :get, "http://cubecomps.com/live.php?cid=418&cat=1&rnd=1&dnrd=1", [
      { response: File.read(Rails.root.join "spec", "fixtures", "cubecomps", "2014-02-28", "delhi-open", "rubiks-cube", "combined-first-not-full.html") },
      { response: File.read(Rails.root.join "spec", "fixtures", "cubecomps", "2014-02-28", "delhi-open", "rubiks-cube", "combined-first.html") }
    ]
  end

  it "should add live tag for 15 minutes after last change" do
    visit competition_events_path(418)
    expect(page).to have_no_css "span.ui-li-count", text: "Live!"

    visit competition_event_round_results_path(418, 1, 1)
    visit competition_events_path(418)
    expect(page).to have_css "span.ui-li-count", text: "Live!"

    Delorean.jump 14.minutes

    visit competition_events_path(418)
    expect(page).to have_css "span.ui-li-count", text: "Live!"

    Delorean.jump 2.minutes

    visit competition_events_path(418)
    expect(page).to have_no_css "span.ui-li-count", text: "Live!"

    visit competition_event_round_results_path(418, 1, 1)
    visit competition_events_path(418)
    expect(page).to have_css "span.ui-li-count", text: "Live!"

    Delorean.back_to_1985
  end
end
