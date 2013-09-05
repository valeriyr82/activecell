
# 4 workers and 1 master if production
rails_env = ENV['RAILS_ENV'] || 'production'
worker_processes (rails_env == 'production' ? 4 : 2)

# Load rails+github.git into the master before forking workers
# for super-fast worker spawn times
preload_app true

# Restart any workers that haven't responded in 30 seconds
timeout 30

before_fork do |server, worker|
  ##
  # When sent a USR2, Unicorn will suffix its pidfile with .oldbin and
  # immediately start loading up a new version of itself (loaded with a new
  # version of our app). When this new Unicorn is completely loaded
  # it will begin spawning workers. The first worker spawned will check to
  # see if an .oldbin pidfile exists. If so, this means we've just booted up
  # a new Unicorn and need to tell the old one that it can now die. To do so
  # we send it a QUIT.
  #
  # Using this method we get 0 downtime deploys.

  old_pid = Rails.root + '/tmp/pids/unicorn.pid.oldbin'
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
  
  # # If you are using Redis but not Resque, change this
  # if defined?(Resque)
  #   Resque.redis.quit
  #   Rails.logger.info('Disconnected from Redis')
  # end

  # Note: Below is from old Profitably unicorn config in case we need it!
  
  # # Replace with MongoDB or whatever
  # if defined?(ActiveRecord::Base)
  #   ActiveRecord::Base.connection.disconnect!
  #   Rails.logger.info('Disconnected from ActiveRecord')
  # end
  # 
  # 
  # sleep 1
end

after_fork do |server, worker|
  ##
  # Unicorn master loads the app then forks off workers - because of the way
  # Unix forking works, we need to make sure we aren't using any of the parent's
  # sockets, e.g. db connection

  # ActiveRecord::Base.establish_connection
  # CHIMNEY.client.connect_to_server
  # Redis and Memcached would go here but their connections are established
  # on demand, so the master never opens a socket

  # # If you are using Redis but not Resque, change this
  # if defined?(Resque)
  #   Resque.redis = $redis
  #   Rails.logger.info('Connected to Redis')
  # end

  # Note: Below is from old Profitably unicorn config in case we need it!
  
  # # Replace with MongoDB or whatever
  # if defined?(ActiveRecord::Base)
  #   ActiveRecord::Base.establish_connection
  #   Rails.logger.info('Connected to ActiveRecord')
  # end
  # 
end

# @resque_pid = nil

# before_fork do |server, worker|
#   @resque_pid ||= spawn("bundle exec rake environment resque:work QUEUE=*")
# end

# after_fork do |server, worker|
#   defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
# end
