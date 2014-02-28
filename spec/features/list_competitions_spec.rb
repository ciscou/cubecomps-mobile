require 'spec_helper'

feature "List competitions" do
  before do
    FakeWeb.register_uri :get, "http://cubecomps.com/", response: File.read(Rails.root.join "spec", "fixtures", "cubecomps", "2014-02-28", "home.html")

    visit root_path
  end

  it "should list competitions in progress" do
    [
      "Delhi Open"
    ].each do |competition_name|
      expect(page).to have_link competition_name
    end
  end

  it "should list past competitions" do
    [
      "Bucharest Rubik Open",
      "Torneo Cali",
      "SLS Gliwice",
      "Hamburg Open",
      "Singapore Rubik's Cube Competition",
      "SpringSpree RubiMania",
      "Caltech Winter Open",
      "Minx Open",
      "Kaohsiung Winter Open",
      "Heureka Open"
    ].each do |competition_name|
      expect(page).to have_link competition_name
    end
  end

  it "should list upcoming competitions" do
    [
      "Murcia Open",
      "Cannes Open",
      "Piedemonte Rubik Day",
      "Ural Winter",
      "Williams Winter",
      "Back to the Palace",
      "Hallonbergen",
      "Hessen Open",
      "Zonhoven Open",
      "Shepparton Autumn",
      "Zaragoza Open",
      "De Wilg Open",
      "Northpark Adelaide",
      "Open Cube Project",
      "Castellon Open",
      "Moratalla Open Rubik",
      "Mallorca Open Rubik"
    ].each do |competition_name|
      expect(page).to have_link competition_name
    end
  end
end
