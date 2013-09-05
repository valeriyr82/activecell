# NOTE Don't forget that your async mailer jobs will be processed by a separate worker.
# This means that you should resist the temptation to pass database-backed objects as parameters in your mailer and instead pass record identifiers.
# Then, in your delivery method, you can look up the record from the id and use it as needed.
class AsyncMailer < ActionMailer::Base
  include Resque::Mailer
  include AbstractController::Callbacks

  default from: Settings.email_notifications.default_from
end
