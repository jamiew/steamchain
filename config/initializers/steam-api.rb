key = ENV['STEAM_API_KEY']
raise "No STEAM_API_KEY environment variable" if key.blank?
Steam.apikey = key
