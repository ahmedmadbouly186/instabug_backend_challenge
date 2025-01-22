class ChatsController < ApplicationController
  # POST /apps/:token/chats
  def create
    app = App.find_by(token: params[:app_token])
    if app
      # use redis key to use redis atomic increment to handel concurency
      redis_key = "app:#{app.token}:chat_count"
      chat_number = $redis.incr(redis_key)

      # Initialize message_count for the new chat in Redis
      message_count_key = "chat:#{app.token}:#{chat_number}:message_count"
      $redis.set(message_count_key, 0)  # Default message count
      
      # Return the chat_number immediately
      render json: { chat_number: chat_number }, status: :ok

      # Push the job to a queue to persist the chat asynchronously
      ChatCreationJob.perform_async(app.token, chat_number)
    else
      render json: { error: 'App not found' }, status: :not_found
    end
  end

  # GET /chats
  def index
    @chats = Chat.includes(:app) # Eager load the associated App to avoid N+1 queries
    render json: @chats.map { |chat| 
      {
        chat_number: chat.chat_number,
        messages_count: chat.messages_count,
        app_token: chat.app.token # Access the token through the association
      }
    }
  end

  # GET /apps/:token/chats
  def app_chats
    app = App.find_by(token: params[:app_token])

    if app
      chats = app.chats
      render json: chats.map { |chat| 
      {
        chat_number: chat.chat_number,
        messages_count: chat.messages_count,
        app_token: app.token # Access the token through the association
      }
    }
    else
      render json: { error: 'App not found' }, status: :not_found
    end
  end

end
