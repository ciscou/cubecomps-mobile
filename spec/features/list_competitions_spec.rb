require 'spec_helper'

feature "List competitions" do
  before do
    FakeWeb.register_uri :get, "http://cubecomps.com/", response: File.read(Rails.root.join "spec", "fixtures", "cubecomps", "2018-09-19", "home.html")

    visit root_path
  end

  it "should list competitions in progress" do
    [
      # TODO download again this weekend!
    ].each do |competition_name|
      expect(page).to have_link competition_name
    end
  end

  it "should list past competitions" do
    [
      "Cube Factory Częstochowa",
      "KSF Semey City",
      "Canarias Open",
      # ...
      "Hillsboro Open"
    ].each do |competition_name|
      expect(page).to have_link competition_name
    end
  end

  it "should list upcoming competitions" do
    [
      "Villa Open",
      "Swiss Nationals",
      "Belgorod Open",
      # ...
      "Manchester Open"
    ].each do |competition_name|
      expect(page).to have_link competition_name
    end
  end
end
