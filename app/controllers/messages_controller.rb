class MessagesController < ApplicationController
  # POST /apps/:app_token/chats/:chat_number/messages
  def create
    app = App.find_by(token: params[:app_token])

    if app
      chat = app.chats.find_by(chat_number: params[:chat_number])
      
      if chat
        # Generate a unique message_number atomically using Redis to handel concurency
        redis_key = "chat:#{app.token}:#{chat.chat_number}:message_count"
        puts "redis_key: #{redis_key}"
        message_number = $redis.incr(redis_key)
  
        # Return the message_number immediately
        render json: { message_number: message_number }, status: :ok

        # Push the job to a queue to persist the message asynchronously
        MessageCreationJob.perform_async(app.token, chat.chat_number, message_number, message_params[:body])
      else
        render json: { error: 'Chat not found' }, status: :not_found
      end
    else
      render json: { error: 'App not found' }, status: :not_found
    end
  end

  # GET /messages
  def index
    messages = Message.includes(chat: :app) # Eager load associated Chat and App to avoid N+1 queries
    render json: messages.map { |message| 
      {
        app_token: message.chat.app.token,
        chat_number: message.chat.chat_number,
        message_number: message.message_number,
        body: message.body
      }
    }
  end
  
  # GET /apps/:token/chats/:number/messages?query=text
  def chat_messages
    app = App.find_by(token: params[:app_token])
    if app
      chat = app.chats.find_by(chat_number: params[:chat_number])
  
      if chat
        if params[:q].present?
          messages = Message.search(params[:q], chat.id) 
          formatted_messages = messages.map do |message|
            {
              matching_score: message._score,
              body: message.body,
              message_number: message.message_number,
            }
          end
          render json: formatted_messages
        else
          messages = chat.messages
          formatted_messages = messages.map do |message|
            {
              matching_score: 0,
              body: message.body,
              message_number: message.message_number,
            }
          end
          render json: formatted_messages
        end
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
  