#= require models/recurly/subscription_options.module
SubscriptionOptions = require('./subscription_options')

module.exports = class NewSubscriptionOptions extends SubscriptionOptions
  url: -> "/company_subscriptions/new?plan_code=#{@getPlanCode()}"
