class ChatCreationJob
  include Sidekiq::Job

  def perform(app_token, chat_number)
    Rails.logger.info("Creating chat for app #{app_token} with number #{chat_number}")
    # Find the app by token
    app = App.find_by(token: app_token)

    if app
      # Create the chat record
      chat = app.chats.create(chat_number: chat_number)

      if chat.persisted?
        # Increment the app's chat_count atomically
        app.increment!(:chat_count)
        Rails.logger.info("Chat created successfully for app #{app_token}")
      else
        # Log or handle errors if the chat creation fails
        Rails.logger.error("Failed to create chat for app #{app_token}")
      end
    else
      Rails.logger.error("App not found for token #{app_token}")
    end
  end
end
