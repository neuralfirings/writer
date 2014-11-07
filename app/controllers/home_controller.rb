class HomeController < ApplicationController
  def index
    if current_user
      @logs = Log.where(:user_id => current_user.id).order("created_at ASC")
    end
  end
end
