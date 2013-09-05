module.exports = class Subscription extends Backbone.Model

  getPlanCode: ->
    @get 'plan_code'

  getPlanName: ->
    @get 'plan_name'

  getPlanPrice: ->
    amount_in_cents = @get('plan_unit_amount_in_cents')
    '$' + (amount_in_cents / 100).toFixed(2)

  getPlanIntervalName: ->
    interval_unit = @get('plan_interval_unit')
    switch interval_unit
      when 'months' then 'month'
      else 'year'
