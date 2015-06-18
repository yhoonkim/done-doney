class ReportsController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = User.find(session[:user_id])
    access_token = @user.authorizations.last.access_token


    #Todo
    #1) Sync
    #2) Show tasks and lists
    #3) Handle API xxceptions

    wunderlist = WunderlistApi.new(access_token)
    @lists = wunderlist.get("lists", nil).body
    raise @lists.inspect
  end

private
  def authenticate_user!
    if !user_signed_in?
      redirect_to login_path
    end
  end
end
