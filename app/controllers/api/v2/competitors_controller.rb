class Api::V2::CompetitorsController < ApplicationController
  def show
    @competitor = Competitor.find(params[:competition_id], params[:id])
  end
end
