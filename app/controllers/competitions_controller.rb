class CompetitionsController < ApplicationController
  def index
    @competitions = Competitions.new
  end

  def past
    @competitions = Competitions.new(all: true)
  end
end
