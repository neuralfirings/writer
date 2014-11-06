class HomeController < ApplicationController
  def index
    if current_user
      @log = Log.where(:user_id => current_user.id)
    end
  end
end
