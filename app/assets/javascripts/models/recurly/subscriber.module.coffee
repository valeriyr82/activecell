Subscription = require('models/recurly/subscription')

module.exports = class Subscriber extends Backbone.Model
  hasActiveSubscription: ->
    @get('has_active_subscription?')

  subscriptionIsCancelled: ->
    @get('subscription_is_cancelled?')

  getAccountCode: ->
    @get('account_code')

  getSubscription: ->
    new Subscription(@get('subscription')) if @hasActiveSubscription()

  canUpgrade: ->
    return unless @hasActiveSubscription()
    @getSubscription().getPlanCode() is 'monthly'

  canDowngrade: ->
    return unless @hasActiveSubscription()
    @getSubscription().getPlanCode() is 'annual'

  changePlanTo: (plan_code, options = {}) ->
    $.ajax
      type: 'PUT'
      dataType: 'json'
      url: '/company_subscriptions/upgrade'
      data: plan_code: plan_code
      success: options.success || ->
      error: options.success || ->

  isOverridden: ->
    !@getAccountCode()
