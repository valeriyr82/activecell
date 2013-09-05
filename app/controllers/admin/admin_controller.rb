class Admin::AdminController < ApplicationController
  before_filter :authenticate_admin
  layout 'admin/air', :only => [:air1, :air2, :air3, :air4, :air5]

  private

  LOGIN = 'admin'
  PASSWORD = 'b1978a435cd075afb9f9b3005250dedad30cdd11'
  # admin users should use 'turkeyLeg01' for the password for now

  def authenticate_admin
    authenticate_or_request_with_http_basic do |login, password|
        login == LOGIN && Digest::SHA1.hexdigest(password) == PASSWORD
    end
  end
end
