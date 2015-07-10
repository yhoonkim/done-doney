class ReportsController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = User.find(session[:user_id])
    @user.sync_wunderlist!
    @tasks = @user.lists.first.tasks
    @tasks_todo = @tasks.where(:completed_at => nil).order(original_created_at: :desc)
    @tasks_done = @tasks.where.not(:completed_at => nil).order(completed_at: :desc)

    today_point = @user.point_of_day(Date.today)
    average_point = @user.average_point_of_day(Date.today)

    @tasks_done_summary_json = {today: today_point, average: average_point}.to_json
  end

private
  def authenticate_user!
    if !user_signed_in?
      redirect_to login_path
    end
  end


end
