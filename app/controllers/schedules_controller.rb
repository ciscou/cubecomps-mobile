class SchedulesController < ApplicationController
  def show
    @competition = Competition.find(params[:competition_id])
  end
end
