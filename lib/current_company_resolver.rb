# Helper class used for resolving the current company
# @see {ApplicationController#current_company}
# @see {ApplicationController#current_company_resolver}
class CurrentCompanyResolver
  attr_reader :request_subdomain
  attr_reader :current_user

  # @param [String, nil] request_subdomain subdomain taken from request url or nil
  #   if the subdomain is not present
  # @param [User, nil] current_user logged user or nil
  #   if the user is not logged
  def initialize(request_subdomain, current_user)
    @request_subdomain = request_subdomain
    @current_user = current_user
  end

  # Finds the current company by subdomain if it's present in the url
  # or returns current user's first company when user is logged
  # @return [Company, nil]
  def resolve
    if SubdomainResolver.not_reserved?(request_subdomain)
      Company.find_by_subdomain(request_subdomain)
    else
      return unless current_user.present?
      current_user.first_company
    end
  end
end
