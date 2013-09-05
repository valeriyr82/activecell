class Gravatar
  attr_reader :user_email
  attr_reader :options

  def self.url_for(user_email, options = {})
    new(user_email, options).url
  end

  def initialize(user_email, options = {})
    @user_email = user_email
    @options = options.reverse_merge!(size: 80)
  end

  def url
    "http://gravatar.com/avatar/#{gravatar_id}.png?s=#{size}"
  end

  private

  def gravatar_id
    Digest::MD5::hexdigest(user_email).downcase
  end

  def size
    options[:size]
  end

end
