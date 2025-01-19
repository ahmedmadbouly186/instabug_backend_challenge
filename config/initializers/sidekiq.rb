# config/initializers/sidekiq.rb
Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://localhost:6400/0', size: 10, pool_name: 'internal' }
end
Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://localhost:6400/0', size: 10, pool_name: 'internal' }
end
