# What the timeout for killing busy workers is, in seconds
timeout 60
 
# Whether the app should be pre-loaded
preload_app true
 
# How many worker processes
worker_processes 4
 
# before/after forks

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!

  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection
  ActiveRecord::Base.verify_active_connections!
end