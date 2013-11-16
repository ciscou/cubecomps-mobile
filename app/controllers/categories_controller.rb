class CategoriesController < ApplicationController
  def index
    @competition = Competition.new(id: params[:competition_id])
    @categories = @competition.categories
  end
end
