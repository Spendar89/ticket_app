require "redis"
redis_conf_path = Rails.root.join("config/redis", "#{Rails.env}.conf")
redis_conf = File.read(redis_conf_path)
port = /port.(\d+)/.match(redis_conf)[1]
`redis-server #{redis_conf_path}`
res = `ps aux | grep redis-server`
unless res.include?("redis-server") && res.include?(redis_conf_path.to_s)  
  raise "Couldn't start redis"
  end
$redis = Redis.new(:port => port)