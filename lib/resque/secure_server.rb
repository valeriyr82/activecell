require 'resque/server'

class Resque::SecureServer < Resque::Server

  use Rack::Auth::Basic, "Restricted Area" do |username, password|
    username == Admin::AdminController::LOGIN &&
        Digest::SHA1.hexdigest(password) == Admin::AdminController::PASSWORD
  end

end
