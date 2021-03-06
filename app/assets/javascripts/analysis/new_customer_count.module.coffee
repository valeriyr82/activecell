BaseAnalysis = require('analysis/shared/base_analysis')

module.exports = class NewCustomerCount extends BaseAnalysis
  default: ->
    @newCustomers = app.newCustomers.get
    app.periods.setAnalysis(@)

  calc: (periodId) ->
    newCustomers = @newCustomers(periodId)?.length ? 0
    if newCustomers > 0 then actual: newCustomers else {}

  plan: ->
    @setBackbone app.conversionForecast, stage_id: app.stages.customer().id
