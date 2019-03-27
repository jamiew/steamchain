class UsersController < ApplicationController

  skip_before_action :verify_authenticity_token, only: :oauth_callback
  before_action :require_login, only: :games

  def new
  end

  def oauth_callback
    logger.debug params.to_unsafe_h.inspect
    logger.debug auth_hash.inspect

    user = User.from_omniauth(auth_hash)
    session[:user_id] = user.id
    redirect_to root_url, notice: "Logged in as #{user.login}"

  rescue OmniAuth::Error => e
    flash[:error] = "Error during OAuth: #{e}"
    render :new
  end

  def games
    # FIXME move all this logic into not-a-controller
    username = params[:id] || current_user.login

    @games = User.get_steam_games(username)
    @sorted_games = User.sort_steam_games(@games)
    @total_hours = @sorted_games.inject(0){|t,game| t += game[1] }

    @games = games
  end


private

  def auth_hash
    request.env['omniauth.auth']
  end

end
