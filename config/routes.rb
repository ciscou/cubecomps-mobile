CubecompsMobile::Application.routes.draw do
  resources :competitions, only: :index do
    resources :events, only: :index do
      resources :rounds, only: [] do
        resources :results, only: :index
      end
    end
    resources :competitors, only: [:index, :show]
    resource  :schedule, only: :show
    get :past, on: :collection
  end

  get "/.well-known/acme-challenge/BYoDNGRW5magGqeiHOSjBtcrrw0nJyuzwu8yX69Q33I", to: "certbot_challenge#show"
  get "/.well-known/acme-challenge/81KbcArZH9YYm4xuZW0xa6c5eyQvGdKM2rWYUixGnxY", to: "certbot_challenge#show2"

  root to: "competitions#index"
end
