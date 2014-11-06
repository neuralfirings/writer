class HomeController < ApplicationController
  def index
    @log = Log.where(:user_id => current_user.id)
  end
end
