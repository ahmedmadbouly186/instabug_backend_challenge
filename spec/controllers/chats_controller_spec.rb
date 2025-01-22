require 'rails_helper'
RSpec.describe ChatsController, type: :controller do
  before do
    @app = App.create(name: "Test App", token: "sample_token")
  end

  describe 'POST #create' do
    it 'creates a new chat and returns the correct chat_number' do
      post :create, params: { app_token: @app.token }

      # Check if chat_number is returned
      expect(response).to have_http_status(:ok)
      chat_number = JSON.parse(response.body)['chat_number']

      # Check Redis for the incremented chat_count
      redis_key = "app:#{@app.token}:chat_count"
      expect($redis.get(redis_key).to_i).to eq(chat_number)
    end

    it 'returns 404 if app not found' do
      post :create, params: { app_token: 'invalid_token' }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET #index' do
    it 'returns a list of chats' do
      # Create a chat before making the request
      post :create, params: { app_token: @app.token }

      # Now check if the chat is included in the response
      get :index
      expect(JSON.parse(response.body).size).to eq(1)
    end
  end

  describe 'GET #app_chats' do
    it 'returns all chats for a given app' do
      # Create a chat before making the request
      post :create, params: { app_token: @app.token }

      # Now check if the chat is included for the specific app
      get :app_chats, params: { app_token: @app.token }
      expect(JSON.parse(response.body).size).to eq(1)
    end

    it 'returns 404 if app not found' do
      get :app_chats, params: { app_token: 'invalid_token' }
      expect(response).to have_http_status(:not_found)
    end
  end
end
