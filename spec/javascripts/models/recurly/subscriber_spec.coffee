Subscriber = require('models/recurly/subscriber')

describe 'Recurly.Subscriber', ->

  describe '#hasActiveSubscription', ->
    it 'should return true if comapany has an active subscription', ->
      model = new Subscriber('has_active_subscription?': true)
      expect(model.hasActiveSubscription()).toBeTruthy()

    it 'should return false if company does not have an active subscription', ->
      model = new Subscriber('has_active_subscription?': false)
      expect(model.hasActiveSubscription()).toBeFalsy()

  describe '#subscriptionIsCancelled', ->
    it 'should return true is subscription is cancelled', ->
      model = new Subscriber('subscription_is_cancelled?': true)
      expect(model.subscriptionIsCancelled()).toBeTruthy()

    it 'should return false is subscription is not cancelled', ->
      model = new Subscriber('subscription_is_cancelled?': false)
      expect(model.subscriptionIsCancelled()).toBeFalsy()

  describe '#getSubscription', ->
    describe 'when it has active subscription', ->
      it 'should return subscription', ->
        model = new Subscriber('has_active_subscription?': true)
        expect(model.getSubscription()).toBeDefined()

    describe 'when it does not have active subscription', ->
      it 'should return null', ->
        model = new Subscriber('has_active_subscription?': false)
        expect(model.getSubscription()).toBeUndefined()

  describe '#isOverridden', ->
    it 'should return true when an account code is not defined', ->
      model = new Subscriber('account_code': undefined)
      expect(model.isOverridden()).toBeTruthy()

    it 'should return false when an account code is defined', ->
      model = new Subscriber('account_code': 'some code')
      expect(model.isOverridden()).toBeFalsy()

  describe '#canUpgrade', ->
    describe 'when subscription is not present', ->
      it 'shuld return undefined', ->
        model = new Subscriber()
        expect(model.canUpgrade()).toBeUndefined()

    describe 'when subscriptions is present', ->
      describe 'on monthly plan', ->
        model = new Subscriber('has_active_subscription?': true, subscription: { plan_code: 'monthly' })

        it 'shuld return true', ->
          expect(model.canUpgrade()).toBeTruthy()

      describe 'on annual plan', ->
        model = new Subscriber('has_active_subscription?': true,subscription: { plan_code: 'annual' })

        it 'shuld return true', ->
          expect(model.canUpgrade()).toBeFalsy()

  describe '#canDowngrade', ->
    describe 'when subscription is not present', ->
      it 'shuld return undefined', ->
        model = new Subscriber()
        expect(model.canDowngrade()).toBeUndefined()

    describe 'when subscriptions is present', ->
      describe 'on annual plan', ->
        model = new Subscriber('has_active_subscription?': true, subscription: { plan_code: 'annual' })

        it 'shuld return true', ->
          expect(model.canDowngrade()).toBeTruthy()

      describe 'on monthly plan', ->
        model = new Subscriber('has_active_subscription?': true,subscription: { plan_code: 'monthly' })

        it 'shuld return true', ->
          expect(model.canDowngrade()).toBeFalsy()
