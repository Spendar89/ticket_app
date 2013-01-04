Sidekiq.configure_server do |config|
  config.redis = { :url => 'redis://rediscloud:V3m9nbH6BL6c5qwX@redis-15726.us-east-1-4.1.ec2.garantiadata.com:15726', :namespace => 'tickets' }
end

Sidekiq.configure_client do |config|
  config.redis = { :size => 100000, :url => 'redis://rediscloud:V3m9nbH6BL6c5qwX@redis-15726.us-east-1-4.1.ec2.garantiadata.com:15726', :namespace => 'tickets' }
end