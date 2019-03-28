class User < ApplicationRecord

  # TODO break out into Steam::User or something
  def self.get_all_steam_games
    Rails.logger.debug "User#get_all_steam_games ..."
    Rails.cache.fetch('all_steam_games', expires: 1.day) {
      all_games = Steam::Apps.get_all # 75k+ records like {'appid'=>'...', 'name'=>'...'}
      all_games_by_id = {} # 75k+ is too big to use one Hash[*games.map{...}] call
      all_games.each{|a| all_games_by_id[a['appid']] = a['name'] }
      all_games_by_id
    }
  end

  def self.get_steam_games(username)
    Rails.logger.debug "User#get_steam_games(#{username.inspect}) ..."
    id = Steam::User.vanity_to_steamid(username)
    result = Steam::Player.owned_games(id)
    games = result['games']
    if result['game_count'] != games.length
      raise "Uh oh, Steam 'game_count' and our @games array's length don't match"
    end
    return games
  end

  def self.sort_steam_games(games)
    Rails.logger.debug "User#sort_steam_games ..."
    all_games_by_id = get_all_steam_games
    sorted_games = {}
    games.each do |game|
      game_name = all_games_by_id[game['appid']]
      sorted_games[game_name] = game['playtime_forever']
    end
    return sorted_games
  end


private

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.login = auth.info.nickname
      user.info = auth.info
      user.raw_info = auth.raw_info
    end
  end

end
