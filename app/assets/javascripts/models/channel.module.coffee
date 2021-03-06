Model = require('models/shared/base_model')
utils = require('analysis/shared/utils')

module.exports = class Channel extends Model
  @hasAnalyse 'reach'
  @hasAnalyse 'conversionRate',
  @hasAnalyse 'segmentMix', file: 'channel_segment_mix'
  @hasAnalyse 'churnRate',
  @hasAnalyse 'churnedCustomers',
  @hasAnalyse 'customerVolume',
  @hasAnalyse 'newCustomers',
  @hasAnalyse 'newCustomerCount',

  @hasAnalyse 'churn', plan: (periodId) ->
    result = app.segments.eachIds (segmentId) =>
      segment        = app.segments.get(segmentId)
      prevPeriodId   = app.periods.prevId(periodId)
      customerVolume = utils.specialCondition segment.customerVolume(prevPeriodId)
      segmentMix     = utils.specialCondition @segmentMix(prevPeriodId)?[segmentId]
      churnRate      = segment.churnRate(periodId).plan
      customerVolume * segmentMix * churnRate
    Math.round _.sum(result)

  @hasAnalyse 'conversion', actual: (periodId) ->
    result = {}
    if app.periods.notFuture(periodId)
      customerStageId = app.stages.customer().id
      result[customerStageId] = actual: @newCustomers(periodId)?.length ? 0
    result

  @hasAnalyse 'revenue', actualMap: {from: 'customer_id', to: 'channel_id'}, plan: (periodId) ->
    _.sum app.segments.eachIds (segmentId) =>
      @segmentMix(periodId)[segmentId].plan * app.segments.revenue(periodId, segmentId).plan

  customers: ->
    app.customers.where(channel_id: @id)

  # Stub
  customersRevenue: (periodId) ->
