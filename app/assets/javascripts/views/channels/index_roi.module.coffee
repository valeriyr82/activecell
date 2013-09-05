SalesMarketingExpense = require('analysis/sales_marketing_expense')
Revenue               = require('analysis/revenue')
SalesMarketingRoi     = require('analysis/sales_marketing_roi')
AnalysisView          = require('views/shared/analysis_view')

module.exports = class ChannelsIndexRoiView extends AnalysisView
  chartTitle:    'sales & marketing roi'
  chartSubtitle: ''
  timeFrameDesc: 'trailing 12 months'

  # instantiate the analytics module and set the initial analysis timeframe
  initialize: ->
    @salesMarketingExpense  = new SalesMarketingExpense()
    @revenue                = new Revenue()
    @salesMarketingRoi      = new SalesMarketingRoi()
    @availableTimeframe     = app.periods.range(-18, -1)
    @timeframe              = app.periods.range(-12, -1)

  # refresh and format analysis data given current timeframe
  prepareData: ->
    data = {}
    dimensions:
      'revenue': @revenue
      'sales & marketing expense': @salesMarketingExpense
      'sales & marketing roi': @salesMarketingRoi
    for attribute, klass in dimensions
      data[attribute] = klass.get @timeframe
    for period of @timeframe
      month = period.month()
      for attribute in dimensions.keys
        @table1Data.push period: month, attribute: attribute, value: data[attribute]['actual']
        @table2Data.push period: month, attribute: attribute, value: data[attribute]['plan']
        if period.notFuture
          @chartData.push period: month, attribute: attribute, value: data[attribute]['actual'], class: 'actual'
        else
          @chartData.push period: month, attribute: attribute, value: data[attribute]['plan'], class: 'plan'

  # pass prepared data to tables/charts with appropriate options/config
  renderMain: ->
    chart_params:
      chartType: 'barChart'
      axes: ['period',
        # temp note to aleksey: how do rawData and result play into these?
        { type: 'rawData', variable: 'dependent' },
        { type: 'result',  variable: 'dependent' }]
      options: 
        segmenton: 'attribute'
    table1_params:
      axes: ['period', 'attribute', 'value']
      options: 
        displayrowtotal: false
        displaycolumntotal: false
    table2_params:
      axes: ['period', 'attribute', 'value']
      options: 
        displayrowtotal: false
        displaycolumntotal: false
    super

  # TODO pull dynamically!!!
  metricValue: ->
    app.formatters.twoPlacesCommas(2.845423)
