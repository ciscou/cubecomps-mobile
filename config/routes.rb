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

  namespace "api", defaults: { format: :json } do
    namespace "v1" do
      resources :competitions, only: [:index, :show] do
        resources :competitors, only: :show
        resources :events, only: [] do
          resources :rounds, only: :show
        end
        get :past, on: :collection
      end
    end
  end

  root to: "competitions#index"
end
