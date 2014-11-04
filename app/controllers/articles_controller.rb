class ArticlesController < ApplicationController
  def new
  end 

  def create
    render text: params[:article].inspect
  end
end
