class SubdomainResolver
  # TODO refactor this, move this logic to the other place
  class << self
    # Check domain name on include in reserver list
    #
    # Examples
    #
    #   SubdomainResolver.not_reserved?('my-company')
    #   # => true
    def not_reserved?(subdomain)
      subdomain.present? && (!Company::RESERVED_SUBDOMAINS.include?(subdomain) || (subdomain == 'demo' && Rails.env.demo?) )
    end

    # User in routes
    def request_subdomain_not_reserved?(request)
      subdomain = current_subdomain_from(request)
      not_reserved?(subdomain)
    end

    # Returns the current subdomain
    def current_subdomain_from(request)
      if Rails.env.test? and request.params[:_subdomain].present?
        request.params[:_subdomain]
      else
        request.subdomain
      end
    end
  end

  attr_reader :subdomain
  attr_reader :user

  def initialize(subdomain, user)
    @subdomain = subdomain
    @user      = user
  end

  def not_belongs_to_user?
    if subdomain.present? && subdomain_not_reserved?
      !(user.present? && @user.try(:has_subdomain?, subdomain))
    else
      false
    end
  end

  def subdomain_not_reserved?
    SubdomainResolver.not_reserved?(subdomain)
  end
end
