require 'sidekiq/web'


Rails.application.routes.draw do
  # Health check endpoint
  mount Sidekiq::Web => '/sidekiq'
  get "up" => "rails/health#show", as: :rails_health_check

  get 'chats', to: 'chats#index' # Add this route to fetch all chats
  get 'messages', to: 'messages#index' # Add this route to fetch all messages
  # Define resources for apps with token as a parameter
  resources :apps, param: :token, only: [:create, :index, :show, :update] do
    # Nested resources for chats
    get 'chats', to: 'chats#app_chats'
    resources :chats, only: [:create], param: :number do
      get 'messages', to: 'messages#chat_messages' 
      resources :messages, only: [:create]
    end
  end


  # Define the root path route (optional, can be set to any other route)
  # root "posts#index"
end
