class SessionsController < ApplicationController

  def new
    # raise user_signed_in?.inspect
    if user_signed_in?
      redirect_to report_path
    elsif !cookies.permanent[:access_token].blank?
      auth = Authorization.find_by_access_token(cookies.permanent[:access_token])
      session[:user_id] = auth.user.id
      redirect_to report_path
    end
  end

  def create

    auth_hash = request.env['omniauth.auth']

    if session[:user_id]
      # Means our user is signed in. Add the authorization to the user
      User.find(session[:user_id]).add_provider(auth_hash)
      render :text => "You can now login using #{auth_hash["provider"].capitalize} too!"
    else
      access_token = WunderlistApi.get_access_token(params[:code])

      # Log him in or sign him up
      auth = Authorization.find_or_create(auth_hash)
      auth.update(access_token: access_token)
      auth.save

      cookies.permanent[:access_token] = access_token


      # Create the session
      session[:user_id] = auth.user.id
    end

    redirect_to report_path
    # render :text => "Welcome #{auth.user.name}!"

  end

  def failure
    render :text => "Sorry, but you didn't allow access to our app!"
  end

  def destroy
    session[:user_id] = nil
    cookies.permanent[:access_token] = nil
    redirect_to root_path
  end

end
