require 'redis'

$redis = Redis.new(host: 'localhost', port: 6400) # Change 'localhost' to the Docker container's IP or hostname if needed
Rails.application.config.after_initialize do
  App.find_each do |app|
    redis_key = "app:#{app.token}:chat_count"
    $redis.setnx(redis_key, app.chat_count)  # Initialize chat_count in Redis if not already set
  end
  Chat.find_each do |chat|
    redis_key = "chat:#{chat.app_id}:#{chat.chat_number}:message_count"
    $redis.setnx(redis_key, chat.messages.maximum(:message_number) || 0)
  end
end
# redis_host = Rails.application.secrets.redis && Rails.application.secrets.redis['host'] || 'localhost'
# redis_port = Rails.application.secrets.redis && Rails.application.secrets.redis['port'] || 6400

# # The constant below will represent ONE connection, present globally in models, controllers, views etc for the instance. No need to do Redis.new everytime
# REDIS = Redis.new(host: redis_host, port: redis_port.to_i)
