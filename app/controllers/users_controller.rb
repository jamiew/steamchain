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
    id = Steam::User.vanity_to_steamid(username)

    all_games = Steam::Apps.get_all # 75k+ records like {'appid'=>'...', 'name'=>'...'}
    all_games_by_id = {} # 75k+ is too big to use one Hash[*games.map{...}] call
    all_games.each{|a| all_games_by_id[a['appid']] = a['name'] }
    puts "Found #{all_games_by_id.length} total games on Steam"

    result = Steam::Player.owned_games(id)

    @games = result['games']
    if result['game_count'] != @games.length
      raise "Uh oh, Steam 'game_count' and our @games array's length don't match"
    end

    @sorted_games = {}
    @games.each do |game|
      game_name = all_games_by_id[game['appid']]
      @sorted_games[game_name] = game['playtime_forever']
    end

    @total_hours = @sorted_games.inject(0){|t,game|
      t += game[1]
    }

    @games = games
  end

private

  def auth_hash
    request.env['omniauth.auth']
  end

end
