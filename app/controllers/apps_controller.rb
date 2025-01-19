class AppsController < ApplicationController
  
  include RetrieveApp

  before_action :find_app, only: [:show]

  # POST /apps
  def create
    @app = App.new(app_params)
    @app.token = SecureRandom.hex(16)  # Generate a unique token

    if @app.save
      # Initialize the Redis key for the app's chat_count
      redis_key = "app:#{@app.token}:chat_count"
      $redis.set(redis_key, @app.chat_count)  # Initialize with 0 (default)
      
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
    @app = App.find_by(token: params[:token])
    if @app.update(app_params)
      # update app in cache
      $redis.set("app:#{params[:token]}", @app.to_json)
      render json: { name: @app.name, chat_count: @app.chat_count }
    else
      render json: @app.errors, status: :unprocessable_entity
    end
  end

  private  
  
  def app_params
    params.require(:app).permit(:name)  # Only allow the name to be passed
  end
end
  