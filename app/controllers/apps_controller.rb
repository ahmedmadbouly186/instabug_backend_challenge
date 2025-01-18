class AppsController < ApplicationController
    before_action :set_app, only: [:show, :update]
  
    # POST /apps
    def create
      @app = App.new(app_params)
      @app.token = SecureRandom.hex(16)  # Generate a unique token
  
      if @app.save
        render json: { token: @app.token, name: @app.name, chat_count: @app.chat_count }, status: :created
      else
        render json: @app.errors, status: :unprocessable_entity
      end
    end
  
    # GET /apps
    def index
      @apps = App.all
      render json: @apps.as_json(only: [:name, :token, :chat_count])
    end
  
    # GET /apps/:token
    def show
      render json: @app.as_json(only: [:name, :chat_count])
    end
  
    # PATCH/PUT /apps/:token
    def update
      if @app.update(app_params)
        render json: { name: @app.name, chat_count: @app.chat_count }
      else
        render json: @app.errors, status: :unprocessable_entity
      end
    end
  
    private
  
    def set_app
      @app = App.find_by(token: params[:token])
      render json: { error: 'App not found' }, status: :not_found unless @app
    end
  
    def app_params
      params.require(:app).permit(:name)  # Only allow the name to be passed
    end
end
  