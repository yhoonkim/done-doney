class ReportsController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = User.find(session[:user_id])

    @raw_lists = @user.lists
    @user.sync_wunderlist!
    @lists = @user.lists
    #Todo
    #1) Sync
    #3) Handle API xxceptions


    # @lists = User.find(session[:user_id]).lists

  end

private
  def authenticate_user!
    if !user_signed_in?
      redirect_to login_path
    end
  end


end
