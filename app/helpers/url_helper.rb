module UrlHelper
  def url_for(options = nil)
    if cannot_use_subdomain?
      if options.kind_of?(Hash) && options.has_key?(:subdomain)
        options[:_subdomain] = options[:subdomain]
      end
    end

    super(options)
  end

  # Simple workaround for integration tests.
  # On test environment (host: 127.0.0.1) store current subdomain in the request param :_subdomain.
  def default_url_options(options = {})
    if cannot_use_subdomain?
      { _subdomain: current_subdomain }
    else
      {}
    end
  end

  private

  # Returns true when subdomains cannot be used.
  # For example when the application is running in selenium/webkit test mode.
  def cannot_use_subdomain?
    (Rails.env.test? or Rails.env.development?) and request.host == '127.0.0.1'
  end
end
