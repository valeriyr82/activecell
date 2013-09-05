module GravatarHelper

  # Generates gravatar url for the given email address
  def avatar_url_for(user_email)
    Gravatar.url_for(user_email)
  end

  def default_avatar_url
    user_email = Settings.email_notifications.default_avatar_email
    Gravatar.url_for(user_email)
  end
end
