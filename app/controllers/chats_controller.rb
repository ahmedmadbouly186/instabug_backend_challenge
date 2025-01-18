class ChatsController < ApplicationController
  # POST /apps/:token/chats
  def create
    app = App.find_by(token: params[:app_token]) # Find the app by token

    if app
      chat = app.chats.build # Build the chat from the app
      
      if chat.save
        app.increment!(:chat_count) # Increment chat_count for the app
        # Return the created chat (without ID)
        render json: chat.as_json(except: :id)
      else
        render json: chat.errors, status: :unprocessable_entity
      end
    else
      render json: { error: 'App not found' }, status: :not_found
    end
  end

  # GET /chats
  def index
    @chats = Chat.all
    render json: @chats.as_json(only: [:chat_number, :messages_count])
  end

  def app_chats
    app = App.find_by(token: params[:app_token])

    if app
      chats = app.chats
      render json: chats.as_json(only: [:chat_number, :message_count, :created_at, :updated_at])
    else
      render json: { error: 'App not found' }, status: :not_found
    end
  end

end
