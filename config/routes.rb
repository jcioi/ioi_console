Rails.application.routes.draw do
  constraints subdomain: 'console' do
    scope module: 'admin' do
      resources :sessions, only: %i(new destroy), as: :admin_sessions
      get '/auth/:provider/callback' => 'sessions#create'

      get '/' => 'dashboard#index'
      resources :teams
    end
  end
end
