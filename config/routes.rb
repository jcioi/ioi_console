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

      resources :machines do
        collection do
          post :import
        end
      end

      resources :password_tiers do
        resources :passwords, only: %i(index) do
          collection do
            post :generate
          end
        end
      end

      resources :contests do
      end

    end
  end

  constraints subdomain: 'leader' do
    scope module: 'leader' do
      get '/', to: redirect('/contestants')
      resources :contestants, only: %i(index edit update)
    end
  end

  resources :sessions, only: %i(new create destroy)
end
