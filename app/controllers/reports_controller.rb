class ReportsController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = User.find(session[:user_id])
    access_token = @user.authorizations.last.access_token


    #Todo
    #1) Sync
    #3) Handle API xxceptions

    wunderlist = WunderlistApi.new(access_token)
    @raw_lists = JSON.parse(wunderlist.get("lists", nil).body, {symbolize_names: true})

  end

private
  def authenticate_user!
    if !user_signed_in?
      redirect_to login_path
    end
  end

  def sync_wunderlist(access_token)
    #0 Compare the root revision
    #1 Get all of lists, tasks, and subtasks

    #2 Add new lists
    #3 Delete removed lists
    #4 Compare the list revision and update them which are bigger than saved one

    #5 Sync Tasks, SubTasks under the changed lists

  end
end
