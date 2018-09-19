class Api::V1::CompetitionsController < ApplicationController
  def index
    @competitions = Competitions.new
  end

  def past
    @competitions = Competitions.new(all: true)
  end

  def show
    @competition = Competition.find(params[:id])
  end
end
