require 'redis'

$redis = Redis.new(host: 'redis', port: 6400)
# $redis = Redis.new(host: 'localhost', port: 6400)
Rails.application.config.after_initialize do
  Rails.logger.info("Checking database connection for Redis initialization...")

  if ActiveRecord::Base.connected? && ActiveRecord::Base.connection.table_exists?('apps') && ActiveRecord::Base.connection.table_exists?('chats')
    Rails.logger.info("Database connected and tables exist. Initializing Redis keys...")

    App.find_each do |app|
      redis_key = "app:#{app.token}:chat_count"
      $redis.setnx(redis_key, app.chat_count)
    end

    Chat.find_each do |chat|
      redis_key = "chat:#{chat.app_id}:#{chat.chat_number}:message_count"
      $redis.setnx(redis_key, chat.messages.maximum(:message_number) || 0)
    end

    Rails.logger.info("Redis initialization complete.")
  else
    Rails.logger.warn("Database not connected or tables do not exist. Skipping Redis initialization.")
  end
end
