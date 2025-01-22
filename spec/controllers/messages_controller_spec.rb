require 'rails_helper'

RSpec.describe MessagesController, type: :controller do
  let(:app) { create(:app) }
  let(:chat) { create(:chat, app: app) }
  let(:valid_message_params) { { body: "Hello, world!" } }
  let(:invalid_message_params) { { body: nil } }

  describe "POST #create" do
    it "creates a new message and returns the correct message_number" do
      expect {
        post :create, params: { app_token: app.token, chat_number: chat.chat_number, message: valid_message_params }
      }.to change { chat.messages.count }.by(1)

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['message_number']).to be_present
    end

    it "returns 404 if app not found" do
      post :create, params: { app_token: 'invalid_token', chat_number: chat.chat_number, message: valid_message_params }
      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 if chat not found" do
      post :create, params: { app_token: app.token, chat_number: 'invalid_chat_number', message: valid_message_params }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET #index" do
    it "returns a list of messages" do
      create(:message, chat: chat)
      get :index
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(1)
    end
  end

  describe "GET #chat_messages" do
    it "returns messages from a specific chat" do
      create(:message, chat: chat)
      get :chat_messages, params: { app_token: app.token, chat_number: chat.chat_number }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(1)
    end

    it "returns 404 if app not found" do
      get :chat_messages, params: { app_token: 'invalid_token', chat_number: chat.chat_number }
      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 if chat not found" do
      get :chat_messages, params: { app_token: app.token, chat_number: 'invalid_chat_number' }
      expect(response).to have_http_status(:not_found)
    end
  end
end
