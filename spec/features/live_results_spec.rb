require 'spec_helper'

feature "Live results" do
  before do
    FakeWeb.register_uri :get, "https://cubecomps.com/live.php?cid=418&dnrd=1", [
      { response: File.read(Rails.root.join "spec", "fixtures", "cubecomps", "2014-02-28", "delhi-open.html") },
      { response: File.read(Rails.root.join "spec", "fixtures", "cubecomps", "2014-02-28", "delhi-open.html") },
      { response: File.read(Rails.root.join "spec", "fixtures", "cubecomps", "2014-02-28", "delhi-open.html") },
      { response: File.read(Rails.root.join "spec", "fixtures", "cubecomps", "2014-02-28", "delhi-open.html") },
      { response: File.read(Rails.root.join "spec", "fixtures", "cubecomps", "2014-02-28", "delhi-open.html") },
      { body: "Too Many Requests", status: [429, "Too Many Requests"] }
    ]
    FakeWeb.register_uri :get, "https://cubecomps.com/live.php?cid=418&cat=1&rnd=1&dnrd=1", [
      { response: File.read(Rails.root.join "spec", "fixtures", "cubecomps", "2014-02-28", "delhi-open", "rubiks-cube", "combined-first-not-full.html") },
      { response: File.read(Rails.root.join "spec", "fixtures", "cubecomps", "2014-02-28", "delhi-open", "rubiks-cube", "combined-first.html") },
      { body: "Too Many Requests", status: [429, "Too Many Requests"] }
    ]
    FakeWeb.register_uri :get, "https://cubecomps.com/uploads/sch_418.txt", [
      { response: File.read(Rails.root.join "spec", "fixtures", "cubecomps", "2014-02-28", "sch_418.txt") },
      { response: File.read(Rails.root.join "spec", "fixtures", "cubecomps", "2014-02-28", "sch_418.txt") },
      { response: File.read(Rails.root.join "spec", "fixtures", "cubecomps", "2014-02-28", "sch_418.txt") },
      { response: File.read(Rails.root.join "spec", "fixtures", "cubecomps", "2014-02-28", "sch_418.txt") },
      { response: File.read(Rails.root.join "spec", "fixtures", "cubecomps", "2014-02-28", "sch_418.txt") },
      { body: "Too Many Requests", status: [429, "Too Many Requests"] }
    ]
  end

  it "should add live tag for 15 minutes after last change", js: true do
    visit competition_events_path(418)
    within("#event-1") { click_link "Rubik's Cube" }
    expect(page).to have_no_css "span.ui-li-count", text: "Live!"

    visit competition_event_round_results_path(418, 1, 1)
    visit competition_events_path(418)
    within("#event-1") { click_link "Rubik's Cube" }
    expect(page).to have_css "span.ui-li-count", text: "Live!"

    Delorean.jump 14.minutes

    visit competition_events_path(418)
    within("#event-1") { click_link "Rubik's Cube" }
    expect(page).to have_css "span.ui-li-count", text: "Live!"

    Delorean.jump 2.minutes

    visit competition_events_path(418)
    within("#event-1") { click_link "Rubik's Cube" }
    expect(page).to have_no_css "span.ui-li-count", text: "Live!"

    visit competition_event_round_results_path(418, 1, 1)
    visit competition_events_path(418)
    within("#event-1") { click_link "Rubik's Cube" }
    expect(page).to have_css "span.ui-li-count", text: "Live!"

    Delorean.back_to_1985
  end
end
