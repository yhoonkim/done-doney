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

    @tasks_due = @user.due_tasks_of_week.sort { |a, b| a.due_date <=> b.due_date }

    today_point = @user.point_of_day(today)
    average_point = @user.average_point_of_day(today)

    @tasks_done_summary_json = {today: today_point, average: average_point}.to_json

  end

  def change_point
    @user = User.find(session[:user_id])
    auth = @user.authorizations.last
    access_token = auth.access_token
    wunderlist = WunderlistApi.new(access_token)



    if(params[:which] == "task")

      @task = Task.find(params[:id])
      request_data = { title: @task.title_with_new_point(params[:point]), revision: @task.revision }
      response = wunderlist.patch("tasks/#{params[:id]}", request_data)

      respond_to do |format|
        if response[:id]
          if @task.update(point: params[:point], title: response[:title], revision: response[:revision]  )
            format.json { render json: { text: "ok!" }, status: 200 }
          else
            format.json { render json: { error: @task.errors.full_messages }, status: 403 }
          end
        else
          format.json { render json: { error: response[:error][:message] }, status: 403 }
        end
      end

    elsif(params[:which] == "subtask")

      @subtask = Subtask.find(params[:id])
      request_data = { title: @subtask.title_with_new_point(params[:point]), revision: @subtask.revision }
      response = wunderlist.patch("subtasks/#{params[:id]}", request_data)

      respond_to do |format|
        if response[:id]
          if @subtask.update(point: params[:point], title: response[:title], revision: response[:revision]  )
            format.json { render json: { text: "ok!" }, status: 200 }
          else
            format.json { render json: { error: @subtask.errors.full_messages }, status: 403 }
          end
        else
          format.json { render json: { error: response[:error][:message] }, status: 403 }
        end
      end

    end
  end

private
  def authenticate_user!
    if !user_signed_in?
      redirect_to login_path
    end
  end


end
