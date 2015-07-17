class ReportsController < ApplicationController
  before_action :authenticate_user!

  def index
    today = Date.today

    @user = User.find(session[:user_id])
    @user.sync_wunderlist!
    @tasks = @user.lists.first.tasks

    @tasks_todo = @user.todo_tasks({without_due_tasks: true})
    @tasks_todo = @tasks_todo.sort { |a, b| b.original_created_at <=> a.original_created_at }

    @tasks_done = @user.done_tasks_of_week(today, {last_two_weeks: true})
    @tasks_done = @tasks_done.sort { |a, b| b.partly_completed_at <=> a.partly_completed_at }

    @tasks_due = @user.due_tasks_of_week(today)

    today_point = @user.point_of_day(today)
    average_point = @user.average_point_of_day(today)

    @tasks_done_summary_json = {today: today_point, average: average_point}.to_json
  end

private
  def authenticate_user!
    if !user_signed_in?
      redirect_to login_path
    end
  end


end
