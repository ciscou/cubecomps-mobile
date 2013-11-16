class ResultsController < ApplicationController
  def index
    @competition = Competition.new(id: params[:competition_id])
    @category = Category.new(id: params[:category_id])
    @round = Round.new(competition_id: @competition.id, category_id: @category.id, id: params[:round_id])
    @results = @round.results
  end
end
