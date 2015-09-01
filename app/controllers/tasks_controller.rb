class TasksController < ApplicationController
  def create

    @user = User.find(session[:user_id])
    @task = Task.new(task_params)
    @task.title = @task.title_with_new_point(@task.point)
    @task.original_created_at = Time.now
    @task.list = @user.memberships.first.list



    if @task.save
      auth = @user.authorizations.last
      access_token = auth.access_token
      wunderlist = WunderlistApi.new(access_token)

      request_data = { list_id: @task.list.id, title: @task.title, due_date: @task.due_date }
      response = wunderlist.post("tasks", request_data)

      if response[:error]
        flash[:errors] = 'Sync error!'
        json_response = { json: { responseText: 'Sync error!' }, status: 403 }
      else
        flash[:successes] = ['Added!']
        json_response = { json: { responseText: 'Added!' }, status: 200 }
      end
    else
      flash[:errors] = @task.errors.full_messages
      json_response = { json: { responseText: @task.errors.full_messages }, status: 403 }
    end

    respond_to do |format|
      format.html { redirect_to report_path() }
      format.json { render json_response }
    end

  end
  def update
  end
  def destroy
  end
private
  def task_params
    params.require(:task).permit(:title, :point, :due_date)
  end
end
