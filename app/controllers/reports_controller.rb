class ReportsController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = User.find(session[:user_id])
    # @user.sync_wunderlist!
    @tasks = @user.lists.first.tasks
    @tasks_todo = @tasks.select { |t| !t.completed_at }
    @tasks_done = @tasks.select { |t| t.completed_at }
  end

private
  def authenticate_user!
    if !user_signed_in?
      redirect_to login_path
    end
  end


end
