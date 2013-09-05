require 'resque/status_server'

if ENV['REDISTOGO_URL'].present?
  uri = URI.parse(ENV["REDISTOGO_URL"])
  Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
end

# Load jobs
Dir["#{Rails.root}/app/jobs/*.rb"].each { |file| require file }
