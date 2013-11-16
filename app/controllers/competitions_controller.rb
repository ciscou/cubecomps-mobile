class CompetitionsController < ApplicationController
  def index
    @competitions = Competitions.new
  end
end
