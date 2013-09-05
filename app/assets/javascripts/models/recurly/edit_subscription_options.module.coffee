SubscriptionOptions = require('./subscription_options')

module.exports = class EditSubscriptionOptions extends SubscriptionOptions
  url: -> '/company_subscriptions/edit'
