class MessagesController < ApplicationController
  # POST /apps/:app_token/chats/:chat_number/messages
  def create
    app = App.find_by(token: params[:app_token])

    if app
      chat = app.chats.find_by(chat_number: params[:chat_number])
      
      if chat
        # Generate a unique message_number atomically using Redis to handel concurency
        redis_key = "chat:#{app.id}:#{chat.chat_number}:message_count"
        message_number = $redis.incr(redis_key)
  
        # Return the message_number immediately
        render json: { message_number: message_number }, status: :ok

        # Push the job to a queue to persist the message asynchronously
        MessageCreationJob.perform_async(chat.id, message_number, message_params[:body])
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
    render json: messages.as_json(except: [:id, :chat_id])
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
              created_at: message.created_at,
              updated_at: message.updated_at
            }
          end
          render json: formatted_messages
        else
          messages = chat.messages
          render json: messages.as_json(except: [:id, :chat_id])
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
  