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

  desc "Fetch list of Steam user's games. Specify USERNAME=foobar"
  task :test => :environment do

    username = ENV['USERNAME'].present? ? ENV['USERNAME'] : "jamiedubs"
    puts "Fetching stats for #{username} ..."

    games = User.get_steam_games(username)
    sorted = User.sort_steam_games(games)

    puts "Top 5 games:"
    sorted.sort_by{|k,v| v}.reverse[0..4].each do |game,minutes|
      puts "* #{game}: #{(minutes/60.0).round(1)} hours"
    end

    total_hours = sorted.inject(0){|t,game| t += game[1] }

    puts "#{games.length} games owned"
    puts "#{total_hours/60} total hours played (#{(total_hours/60/24.0).round(1)} days)"
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
