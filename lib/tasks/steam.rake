namespace :steam do

  def steam_app_details(app_id)
    url = "https://store.steampowered.com/api/appdetails?appids=#{app_id}"
    result = Faraday.new(url).get
    json = JSON.parse(result.body)
    if json.present? && json[app_id.to_s]['success'] != true
      raise "Steam API returned JSON, but success=false"
    end
    return json[app_id.to_s]['data']
  end

  desc "Fetch list of Steam user's games"
  task :test => :environment do

    username = "jamiedubs"
    id = Steam::User.vanity_to_steamid(username)
    all_games = Steam::Apps.get_all # 75k+ records like {'appid'=>'...', 'name'=>'...'}
    all_games_by_id = {} # 75k+ is too big to use one Hash[*games.map{...}] call
    all_games.each{|a| all_games_by_id[a['appid']] = a['name'] }
    puts "Found #{all_games_by_id.length} games on Steam"

    result = Steam::Player.owned_games(id)
    games = result['games']
    puts "Player game_count=#{result['game_count']}"
    puts "Player games.length=#{games.length}"

    my_games = {}
    games.each do |game|
      game_name = all_games_by_id[game['appid']]
      my_games[game_name] = game['playtime_forever']
    end

    my_games.sort_by{|k,v| v}.each do |game,minutes|
      puts "#{game}: #{(minutes/60.0).round(1)} hours"
    end

    puts "Done"
  end

  desc 'Run through all the steam-api methods'
  task :test_all => :environment do
    username = "jamiedubs"
    [
      :steam_level,
      :badges,
      :community_badge_progress,
      :owned_games,
      :recently_played_games,
    ].each do |method|
      puts "\nSteam::Player.#{method}:"
      pp Steam::Player.send(method, id)
    end

    [
      :bans,
      :friends,
      :groups,
      # :summaries, # for multiple users
      :summary,
      :vanity_to_steamid,
    ].each do |method|
      puts "\nSteam::User.#{method}:"
      begin
        pp Steam::User.send(method, id)
      rescue Exception => e
        puts "ERROR: #{e}"
      end

    end

    # UserStats
    # for specific games
    [
      :achievement_percentages,
      :game_schema,
      :global_for_game,
      :player_count,
    ].each do |method|
      puts "\nSteam::UserStats.#{method}:"
      pp Steam::UserStats.send(method, game_id)
    end

    # for specific game and specific player
    [
      :player_achievements,
      :player_stats
    ].each do |method|
        puts "\nSteam::UserStats.#{method}:"
        pp Steam::UserStats.send(method, game_id, id)
    end

  end
end