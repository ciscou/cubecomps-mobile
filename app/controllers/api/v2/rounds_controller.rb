class Api::V2::RoundsController < ApplicationController
  def show
    @round = Round.new(competition_id: params[:competition_id], event_id: params[:event_id], id: params[:id])
  end
end
