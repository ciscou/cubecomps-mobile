class ResultsController < ApplicationController
  def index
    @round = Round.new(competition_id: params[:competition_id], event_id: params[:event_id], id: params[:round_id])
  end
end
