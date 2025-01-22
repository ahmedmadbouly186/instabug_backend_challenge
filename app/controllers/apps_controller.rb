class AppsController < ApplicationController
  
  # include RetrieveApp

  # before_action :find_app, only: [:show]
  # after_action :set_app, only: [:update]
  
  # POST /apps
  def create
    @app = App.new(app_params)
    @app.token = SecureRandom.hex(16)  # Generate a unique token
    @app.chat_count = 0  # Initialize chat_count to 0
    
    if @app.save
      # Initialize the Redis key for the app's chat_count
      redis_key = "app:#{@app.token}:chat_count"
      $redis.set(redis_key, @app.chat_count)  # Initialize with 0 (default)
      
      render json: { token: @app.token, name: @app.name, chat_count: @app.chat_count }, status: :created
    else
      Rails.logger.error("App creation failed: #{@app.errors.full_messages.join(', ')}")
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
    @app = App.find_by(token: params[:token])
    if @app.nil?
      render json: { error: 'App not found' }, status: :not_found
      return
    end
    render json: @app.as_json(only: [:name, :chat_count])
  end

  # PATCH/PUT /apps/:token
  def update
    @app = App.find_by(token: params[:token])
    if @app.update(app_params)
      # update app in cache
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
  