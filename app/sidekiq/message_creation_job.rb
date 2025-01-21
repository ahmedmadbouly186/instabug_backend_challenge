class MessageCreationJob
  include Sidekiq::Job

  def perform(app_token, chat_number, message_number, body)
    Rails.logger.info("Creating message for app_token #{app_token} and chat_number #{chat_number},with message_number #{message_number}")
  
    # Find the app by token
    app = App.find_by(token: app_token)
  
    if app
      # Find the chat by app_id and chat_number
      chat = app.chats.find_by(chat_number: chat_number)
  
      if chat
        # Create the message record
        message = chat.messages.create(message_number: message_number, body: body)
        chat_id = chat.id
        if message.persisted?
          # Increment the chat's messages_count atomically
          chat.increment!(:messages_count)
          Rails.logger.info("Message created successfully for chat #{chat_id}")
        else
          # Log or handle errors if the message creation fails
          Rails.logger.error("Failed to create message for chat #{chat_id}")
        end
      else
        Rails.logger.error("Chat not found for ID #{chat_id}")
      end
    else
      Rails.logger.error("App not found for token #{app_token}")
    end
  end
  
end

