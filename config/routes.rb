Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get '/' => 'users#new', as: :new_user
  post '/auth/steam/callback' => 'users#oauth_callback', as: :oauth_callback
  delete '/logout' => 'users#logout', as: :logout

  get '/games' => 'users#games', as: :user_games
  get '/games/:id' => 'users#games'

  root to: 'users#new'
end
