Subscriber          = require('models/recurly/subscriber')
SubscriptionOptions = require('models/recurly/subscription_options')

describe 'Recurly.SubscriptionOptions', ->
  beforeEach ->
    @subsriber = new Subscriber(account_code: 'Account code')
    @attributes =
      subscriber: @subsriber
      account_code: 'Account code'
      signature: 'Signature'
      success_url: 'http://www.example.com/subscriptions'
      company_subdomain: 'profitably'
      default_currency: 'USD'
      plan_code: 'annual'
    @model = new SubscriptionOptions(@attributes)

  describe '#getPlanCode', ->
    it 'should return plan code', ->
      expect(@model.getPlanCode()).toEqual @attributes.plan_code

  describe '#getAccountCode', ->
    it 'should return account code', ->
      expect(@model.getAccountCode()).toEqual('Account code')

  describe '#getSignature', ->
    it 'should return signature', ->
      expect(@model.getSignature()).toEqual('Signature')

  describe '#getSuccessURL', ->
    it 'should reutnr success url', ->
      expect(@model.getSuccessURL()).toEqual('http://www.example.com/subscriptions')

  describe '#getCompanysubdomain', ->
    it 'should return company subdomain', ->
      expect(@model.getCompanySubdomain()).toEqual('profitably')

  describe '#getDefaultCurrency', ->
    it 'should return default currency', ->
      expect(@model.getDefaultCurrency()).toEqual('USD')

  describe '#getConfig', ->
    it 'should return recurly config', ->
      config = @model.getConfig()
      expect(config.subdomain).toEqual @attributes.company_subdomain
      expect(config.currency).toEqual  @attributes.default_currency

  describe '#buildOptions', ->
    it 'should build options for new subscription form', ->
      options = @model.buildOptions(target: '#test-id')
      expect(options.target).toEqual('#test-id')
      expect(options.signature).toEqual(@attributes.signature)
      expect(options.accountCode).toEqual(@subsriber.getAccountCode())
      expect(options.successURL).toEqual(@attributes.success_url)
