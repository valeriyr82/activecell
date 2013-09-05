module.exports = class Company extends Backbone.Model
  paramRoot: 'company'
  urlRoot: 'api/v1/companies'

  validate:
    name:
      required: true
    url:
      required: true
      type: 'url'

  initialize: ->
    Companies  = require('collections/companies')
    @advisedCompanies = new Companies(@get 'advised_companies')

  getUserIds: ->
    @get('user_ids_count') || 0

  isAdvisor: ->
    @get('_type') is 'AdvisorCompany'

  isAdvised: ->
    not @isAdvisor() and @get('is_advised')

  # Returns true if an account is in trial period
  isInTrial: ->
    @get('is_in_trial')

  # Returns true if trial expired
  isTrialExpired: ->
    @get('is_trial_expired')

  isBrandingOverridden: ->
    @get('is_branding_overridden')

  # Returns number of trial days left
  trialDaysLeft: ->
    @get('trial_days_left')

  isConnectedToIntuit: ->
    @get('is_connected_to_intuit')

  toggleAdvisor: (options = {}) ->
    @_ajaxPut
      url: if @isAdvisor() then "#{@url()}/downgrade" else "#{@url()}/upgrade"
      success: =>
        type = if @isAdvisor() then 'Company' else 'AdvisorCompany'
        @set('_type', type)
        options.success?.call(@, @)

  inviteUser: (email, options = {}) ->
    ignoreIfAdvisor = options.ignoreIfAdvisor ? false
    _.extend options,
      url: "#{@url()}/invite_user"
      data:
        user: {email: email},
        ignoreIfAdvisor : ignoreIfAdvisor
    @_ajaxPut(options)

  inviteAdvisorByCompany: (id, options = {}) ->
    _.extend options,
      url: "#{@url()}/invite_advisor"
      data: company: id: id
    @_ajaxPut(options)

  usersCount: (callback = ()->) ->
    response = @_ajax
      url: "#{@url()}/users_count"
      success: (count) =>
        callback.call(@, count)
    
  # Remove user from the company
  removeUser: (user, options = {}) ->
    @_ajaxPut
      url: "#{@url()}/remove_user"
      data:
        user: id: user.get('id')
      success: =>
        options.success?.call()

        # Decrease the amount of user ids assigned to this company
        userIds = @getUserIds()
        userIds = if userIds > 0 then userIds - 1 else userIds
        @set('user_ids_count', userIds)

  # Remove company from advised
  removeAdvisedCompany: (options = {}) ->
    @_ajaxPut
      url: "#{app.company.url()}/remove_advised_company"
      data:
        company: id: @get('id')
      success: =>
        options.success?.call()

  # Create new, advised company
  createAdvisedCompany: (options = {}) ->
    @_ajaxPost _.extend(options, url: "#{@url()}/create_advised_company")

  # Create new company
  create: (options = {}) ->
    @_ajaxPost _.extend(options, url: @urlRoot)

  resetLogo: (options = {}) ->
    @_ajaxPut
      url: "/api/v1/company_branding"
      data:
        JSON.stringify(company_branding: logo: null)
      contentType: 'application/json'
      success: options.success
      error: options.error

  scheduleBackgroundEtlJob: (options = {}) ->
    return unless @isConnectedToIntuit()

    options.url = '/api/v1/background_jobs'
    @_ajaxPost(options)

  # Private method
  # Sends ajax PUT request via jQuery.ajax
  _ajaxPut: (options = {}) ->
    @_ajax _.extend(options, type: "PUT")

  _ajaxPost: (options = {}) ->
    @_ajax _.extend(options, type: "POST")

  _ajax: (options = {}) ->
    options.type ||= "GET"
    options.url ||= @url()
    options.dataType ||= 'json'
    options.success ||= ->
    options.error ||= ->

    $.ajax(options)
