module.exports = class SubscriptionOptions extends Backbone.Model
  initialize: (options = {}) ->
    @planCode = options.plan_code || 'monthly'
    @subscriber = options.subscriber || app.subscriber

  getPlanCode: ->
    @planCode

  getAccountCode: ->
    @subscriber.getAccountCode()

  getSignature: ->
    @get('signature')

  getSuccessURL: ->
    @get('success_url')

  getCompanySubdomain: ->
    @get('company_subdomain')

  getDefaultCurrency: ->
    @get('default_currency')

  getConfig: ->
    subdomain: @getCompanySubdomain()
    currency: @getDefaultCurrency()

  buildOptions: (options = {}) ->
    defaultOptions =
      signature:   @getSignature()
      accountCode: @getAccountCode()
      planCode:    @getPlanCode()
      successURL:  @getSuccessURL()

    _.extend(defaultOptions, options)
