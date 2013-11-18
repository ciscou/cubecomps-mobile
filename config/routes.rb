CubecompsMobile::Application.routes.draw do
  resources :competitions, only: :index do
    resources :categories, only: :index do
      resources :rounds, only: [] do
        resources :results, only: :index
      end
    end
    get :past, on: :collection
  end

  root to: "competitions#index"
end
