class MessagesController < ApplicationController
  # POST /apps/:app_token/chats/:chat_number/messages
  def create
    app = App.find_by(token: params[:app_token]) # Find the app by token

    if app
      chat = app.chats.find_by(chat_number: params[:chat_number]) # Find the chat by chat_number
      if chat
        message = chat.messages.build(message_params) # Build message associated with chat

        if message.save
          chat.increment!(:messages_count) # Increment messages_count for the chat

          # Return the created message (excluding ID)
          render json: {
          body: message.body,
          app_token: app.token,
          chat_number: chat.chat_number,
          message_number: message.message_number,
          created_at: message.created_at,
          updated_at: message.updated_at
        }
        else
          render json: message.errors, status: :unprocessable_entity
        end
      else
        render json: { error: 'Chat not found' }, status: :not_found
      end
    else
      render json: { error: 'App not found' }, status: :not_found
    end
  end
  
  # GET /messages
  def index
    messages = Message.all
    render json: messages.as_json(except: :id)
  end
  
  # GET /apps/:token/chats/:number/messages
  def chat_messages
    app = App.find_by(token: params[:app_token])

    if app
      chat = app.chats.find_by(chat_number: params[:chat_number])

      if chat
        messages = chat.messages
        render json: messages.as_json(
          only: [:body, :message_number, :created_at, :updated_at],
          # methods: [:app_token, :chat_number]
        )
      else
        render json: { error: 'Chat not found' }, status: :not_found
      end
    else
      render json: { error: 'App not found' }, status: :not_found
    end
  end
  
  private
  
  def message_params
    params.require(:message).permit(:body)
  end


end
  