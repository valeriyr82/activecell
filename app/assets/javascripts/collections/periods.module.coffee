Collection = require('collections/shared/collection')
Period     = require('models/period')

module.exports = class Periods extends Collection
  url: 'api/v1/periods'
  model: Period

  # Order ascending by first_day
  comparator: (period) ->
    moment(period.get('first_day')).unix()

  # Uses as a filter
  #
  # start - Number of months from start
  # end   - Number of months to end
  #
  # Examples:
  #
  #   # current data is 2012-07-03
  #   periods.range(-3, -1)
  #   # => ['2012-04', '2012-05', '2012-06'] - ids of 3 last months
  #
  #   period.range(null, 0)
  #   # => ['2012-03', '2012-04', '2012-05', '2012-06', '2012-07'] - ids of all months to current
  #
  # Returns list of ids which contain current period
  range: (start, end) ->
    startOfMonth = @_startOfMonth().toString()
    startDate    = moment(startOfMonth).add('months', start)
    endDate      = moment(startOfMonth).add('months', end)

    @chain().select((period) ->
      firstDay = moment period.get('first_day')
      (_.isNull(start) or firstDay >= startDate) and (_.isNull(end) or firstDay <= endDate)
    ).pluck('id').value()

  idToMonthString: (periodId) ->
    moment(@get(periodId).get('first_day')).format('MMM')

  idToMonthYearString: (periodId) ->
    moment(@get(periodId).get('first_day')).format('MMM YYYY')
    
  idToYearString: (periodId) ->
    moment(@get(periodId).get('first_day')).format('YYYY')

  idToCompactString: (periodId) ->
    value = moment(@get(periodId).get('first_day')).format('MMM')
    if value is 'Jan'
      value = moment(@get(periodId).get('first_day')).format('YYYY')
    value 
    
  indexToDate: (index) ->
    moment().startOf('month').add('months', index).toDate()
    # d3.time.format("%Y-%m-%d").parse(
    #   moment().startOf('month').add('months', index).format('YYYY-MM-DD')
    # )

  idToDate: (periodId) ->
    d3.time.format("%Y-%m-%d").parse(@get(periodId).get('first_day'))

  notFuture: (periodId) ->
    moment(@get(periodId).get('first_day')) <= @_startOfMonth()

  _startOfMonth: ->
    moment().startOf('month')

  setAnalysis: (analysis) ->
    app.periods.eachIds (periodId) ->
      analysis.set periodId, analysis.calc(periodId)
