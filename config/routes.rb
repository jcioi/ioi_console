Rails.application.routes.draw do
  constraints subdomain: 'console' do
    scope module: 'admin' do
      resources :sessions, only: %i(new destroy), as: :admin_sessions
      get '/auth/:provider/callback' => 'sessions#create'

      get '/' => 'dashboard#index'

      resources :teams do
        collection do
          post :import
        end
      end

      resources :people do
        collection do
          post :import
        end
      end

      resources :desks do
        collection do
          post :import
        end
      end

    end
  end
end
