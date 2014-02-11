class CompetitorsController < ApplicationController
  def index
    @competition = Competition.find(params[:competition_id])
  end

  def show
    @competitor = Competitor.find(params[:competition_id], params[:id])
  end
end
