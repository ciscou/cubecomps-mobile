class Api::V1::CompetitorsController < ApplicationController
  def show
    @competitor = Competitor.find(params[:competition_id], params[:id])
  end
end
