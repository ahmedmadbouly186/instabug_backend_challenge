class MessageCreationJob
  include Sidekiq::Job

  def perform(chat_id, message_number, body)
    Rails.logger.info("Creating message for chat #{chat_id} with number #{message_number}")
    # Find the chat by ID
    chat = Chat.find_by(id: chat_id)

    if chat
      # Create the message record
      message = chat.messages.create(message_number: message_number, body: body)

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
  end
end

