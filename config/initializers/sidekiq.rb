Sidekiq.configure_server do |client|
  client.redis = {
    url: ENV.fetch('REDIS_URL', nil)
  }
end
