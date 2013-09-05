NewSubscriptionOptions = require('models/recurly/new_subscription_options')

describe 'NewSubscriptionOptions', ->
  beforeEach ->
    @attributes =
      plan_code: 'annual'
    @model = new NewSubscriptionOptions(@attributes)

  describe '#url', ->
    it 'should return valid url with plan code', ->
      expect(@model.url()).toEqual("/company_subscriptions/new?plan_code=#{@attributes.plan_code}")

  describe '#fetch', ->
    beforeEach ->
      spyOn($, 'ajax')
      @model.fetch()
      @request = $.ajax.mostRecentCall.args[0]

    it 'should be GET', ->
      expect(@request.type).toEqual('GET')

    it 'should have valid url', ->
      expect(@request.url).toEqual("/company_subscriptions/new?plan_code=#{@attributes.plan_code}")
