Subscription = require('models/recurly/subscription')

describe 'Recurly.Subscription', ->
  beforeEach ->
    @attributes =
      plan_code: 'monthly'
      plan_name: 'Activecell Monthly'
      plan_unit_amount_in_cents: 4990
      plan_interval_unit: 'months'
      state: 'active'
      trial_ends_at: null
      uuid: '199938cadcf4c46f1eeaa447c583204d'

    @model = new Subscription(@attributes)

  describe '#getPlanCode', ->
    it 'rerturn the plan code', ->
      expect(@model.getPlanCode()).toEqual(@attributes.plan_code)

  describe '#getPlanName', ->
    it 'return the plan code', ->
      expect(@model.getPlanName()).toEqual(@attributes.plan_name)

  describe '#getPlanPrice', ->
    it 'return formatted plan price', ->
      expect(@model.getPlanPrice()).toEqual('$49.90')

  describe '#getPlanIntervalName', ->
    describe 'when plan_interval_unit=monthly', ->
      it 'return "month"', ->
        expect(@model.getPlanIntervalName()).toEqual('month')

    describe 'otherwise', ->
      beforeEach ->
        @model.attributes.plan_interval_unit = 'something else'

      it 'return "year"', ->
        expect(@model.getPlanIntervalName()).toEqual('year')
