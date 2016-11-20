class StaticPagesController < ApplicationController

  def index
    @elements = StaticPage.all
  end

  def new
    @element = StaticPage.new
  end

  def show
    @element = StaticPage.find(params[:id])
  end

end
