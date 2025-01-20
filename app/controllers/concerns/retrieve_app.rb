module RetrieveApp
  extend ActiveSupport::Concern

  included do
    before_action :find_app
    after_action :set_app
  end

  private

  def find_app
    token = params[:token] || params[:app_token]

    if token.blank?
      render json: { error: 'Token is required' }, status: :bad_request
      return
    end

    # Check Redis cache
    cached_app = $redis.get("app:#{token}")
    
    if cached_app
      app_data = JSON.parse(cached_app, symbolize_names: true)
      # Convert the cached JSON into an App instance
      @app = App.new(app_data)
      @app.id = app_data[:id]
    else
      @app = App.find_by(token: token)
      if @app
        $redis.setex("app:#{token}", 3600, @app.to_json)
      else
        render json: { error: 'App not found' }, status: :not_found
        return
      end
    end
  end
  def set_app
    # use app token as key
    $redis.setex("app:#{@app.token}", 3600, @app.to_json)
  end
end
