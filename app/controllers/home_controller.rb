class HomeController < ApplicationController
  def index
    @log = Log.all
  end
end
