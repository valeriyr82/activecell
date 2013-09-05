EditSubscriptionOptions = require('models/recurly/edit_subscription_options')

describe 'EditSubscriptionOptions', ->
  beforeEach ->
    @model = new EditSubscriptionOptions()

  describe '#url', ->
    it 'should return valid url with plan code', ->
      expect(@model.url()).toEqual('/company_subscriptions/edit')

  describe '#fetch', ->
    beforeEach ->
      spyOn($, 'ajax')
      @model.fetch()
      @request = $.ajax.mostRecentCall.args[0]

    it 'should be GET', ->
      expect(@request.type).toEqual('GET')

    it 'shoulda have valid url', ->
      expect(@request.url).toEqual('/company_subscriptions/edit')
