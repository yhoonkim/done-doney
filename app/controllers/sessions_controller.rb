class SessionsController < ApplicationController
  def new
  end

  def create
    auth_hash = request.env['omniauth.auth']

    if session[:user_id]
      # Means our user is signed in. Add the authorization to the user
      User.find(session[:user_id]).add_provider(auth_hash)

      render :text => "You can now login using #{auth_hash["provider"].capitalize} too!"
    else


      access_token = WunderlistApi.get_access_token(params[:code])

      #Todo
      #1) access_token 받아오기
      #2) curl 보내는 함수 만들기


      # Log him in or sign him up
      auth = Authorization.find_or_create(auth_hash)
      auth.update(access_token: access_token)
      auth.save

      wunderlist = WunderlistApi.new(access_token)
      lists = wunderlist.get("lists", nil)
      raise lists.body.inspect
      # Create the session
      session[:user_id] = auth.user.id
      render :text => "Welcome #{auth.user.name}!"
    end
  end

  def failure
    render :text => "Sorry, but you didn't allow access to our app!"
  end

  def destroy
    session[:user_id] = nil
    render :text => "You've logged out!"
  end

end
