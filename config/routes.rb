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
            post :print
          end
        end
      end

      resources :contests do
      end

      resources :remote_tasks, only: %i(index new create) do
        resources :remote_task_executions, as: :executions, path: 'executions', only: %i(index show)
      end
    end
  end

  constraints subdomain: 'leader' do
    scope module: 'leader' do
      get '/', to: redirect('/contestants')
      resources :contestants, only: %i(index edit update)
    end
  end

  constraints subdomain: 'service' do
    scope module: 'service' do
      get '/', to: redirect('/hailings')
      resources :hailings, only: %i(index create)
      resource :special_requirement_note, only: %i(edit update)
    end
  end


  get '/site/sha' => RevisionPlate::App.new(File.join(__dir__, '..', 'REVISION'))
  resources :sessions, only: %i(new create destroy)
end
