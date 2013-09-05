BaseAnalysis = require('analysis/shared/base_analysis')

module.exports = class Churn extends BaseAnalysis
  default: ->
    @churnedCustomers = app.churnedCustomers?.get
    app.periods.eachIds (periodId) =>
      segmentsSum = _.sum(values.plan for segmentId, values of app.segments.churn(periodId))
      @set periodId, @calc(periodId)
      @set periodId, plan: segmentsSum

  calc: (periodId) ->
    if churnedCustomers = @churnedCustomers?(periodId)
    then actual: churnedCustomers.length else {}
