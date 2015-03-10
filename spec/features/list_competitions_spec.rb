require 'spec_helper'

feature "List competitions" do
  before do
    FakeWeb.register_uri :get, "http://cubecomps.com/", response: File.read(Rails.root.join "spec", "fixtures", "cubecomps", "2015-03-10", "home.html")

    visit root_path
  end

  it "should list competitions in progress" do
    [
      "Chojnice Cube Day"
    ].each do |competition_name|
      expect(page).to have_link competition_name
    end
  end

  it "should list past competitions" do
    [
      "Rose City Cubing Competition"
    ].each do |competition_name|
      expect(page).to have_link competition_name
    end
  end

  it "should list upcoming competitions" do
    [
      "River Hill Winter",
      "Summit City Open",
      "Back To Cubing Hong Kong",
      "GLS Luty",
      "Linkub",
      "Speed Cubing Mumbai Unlimited",
      "Edmonton Open Winter",
      "Luis's Test Account"
    ].each do |competition_name|
      expect(page).to have_link competition_name
    end
  end
end
