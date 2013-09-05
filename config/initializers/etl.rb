require 'etl'

Dir[Rails.root.to_s + "/config/etl/shared/*.rb"].each {|file| require file }
Dir[Rails.root.to_s + "/config/etl/**/*.rb"].each {|file| require file }
# Configure XML storage
if Rails.env.test?
  Fog.mock!
end

if Rails.env.production?
  Intuit::Api.logger = ETL::Extract::S3Backups.new(
    :provider                 => 'AWS',
    :aws_secret_access_key    => "iWIT46lC+dmlXBYKloy0Atq4ux4jSJ/j99QOM+fs",
    :aws_access_key_id        => "AKIAID2CS52KWKMZ3Y7A",
    :bucket                   => "etl-backups"
  )
end