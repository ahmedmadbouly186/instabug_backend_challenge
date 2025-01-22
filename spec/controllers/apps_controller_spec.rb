require 'rails_helper'

RSpec.describe AppsController, type: :controller do
  let(:valid_attributes) { { name: "MyApp" } }
  let(:invalid_attributes) { { name: nil } }
  let(:app) { create(:app) }

  describe "POST #create" do
    it "creates a new app and returns the correct response" do
      expect {
        post :create, params: { app: valid_attributes }
      }.to change(App, :count).by(1)
      
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)['token']).to be_present
      expect(JSON.parse(response.body)['name']).to eq('MyApp')
    end

    it "does not create a new app and returns errors" do
      expect {
        post :create, params: { app: invalid_attributes }
      }.to change(App, :count).by(0)

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "GET #index" do
    it "returns a list of apps" do
      create(:app)
      get :index
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(1)
    end
  end

  describe "GET #show" do
    it "returns the app if found" do
      get :show, params: { token: app.token }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['name']).to eq(app.name)
    end

    it "returns 404 if app not found" do
      get :show, params: { token: 'invalid_token' }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH #update" do
    it "updates the app" do
      patch :update, params: { token: app.token, app: { name: "UpdatedApp" } }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['name']).to eq("UpdatedApp")
    end

    it "returns 422 if update fails" do
      patch :update, params: { token: app.token, app: { name: nil } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
