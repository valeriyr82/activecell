Reach        = require('analysis/reach')
AnalysisView = require('views/shared/analysis_view')
UpperChartView = require('views/shared/d3_chart/upper_view')

module.exports = class ChannelsIndexReachView extends AnalysisView
  n: 5 # number of categories
  m: 12 # number of x-axis items

  # instantiate the analytics module and set the initial analysis timeframe
  initialize: ->
    super
    # @reach              = new Reach()
    # @availableTimeframe = app.periods.range(-18, 36)
    # @timeframe          = app.periods.range(-5, 6)
    # @x                  = d3.time.scale().range([0, @w])
    # @y                  = d3.scale.linear().range([@h, 0])
  
  renderMain: ->
    @prepareData()
    @renderMainChart()
    @renderHeader()
    # @renderTable()
  
  dashboardOptions: ->
    {
      id: 'reach'
      type: 'column'
      data: [
          {"label":"FL", "val":10000 }
          {"label":"CA", "val":20000 }
          {"label":"NY", "val":30000 }
          {"label":"NC", "val":40000 }
          {"label":"SC", "val":50000 }
          {"label":"AZ", "val":60000 }
          {"label":"TX", "val":70000 }
        ]
    } 
    
  miniChartOptions: ->
    {
      id: 'reach'
      type: 'column'
      data: [
          {"label":"FL", "val":10000 }
          {"label":"CA", "val":20000 }
          {"label":"NY", "val":30000 }
          {"label":"NC", "val":40000 }
          {"label":"SC", "val":50000 }
          {"label":"AZ", "val":60000 }
        ]
    }
  
  prepareData: ->
    # Inspired by Lee Byron's stream_layers test data generator.
    
    n = @n # number of categories
    m = @m # number of x-axis items

    bump = (a) ->
      x = 1 / (.1 + Math.random())
      y = 2 * Math.random() - .5
      z = 10 / (.1 + Math.random())
      _(m).times (i) ->
        w = (i / m - y) * z
        a[i] += x * Math.exp(-w * w)

    stream_index = (d, i) ->
      x: i
      y: Math.max(0, d)

    o = .1

    @data = d3.layout.stack()(d3.range(n).map ->
      a = []
      _(m).times (i) ->
        a[i] = o + o * Math.random()
      _(5).times () ->
        bump a
      a.map stream_index
    )
  
  renderMainChart: () ->
    @mainChartView = @createView UpperChartView, @data
    @$('#main_chart').html @mainChartView.render().el
    
    @mainChartView.series.push {
      id: 'stacked-col'
      type: 'stacked col'
      # category: (d) -> d.category
      # xValue: (d) -> x(d.volume)
      # xLabel: (d) -> app.formatters.usdCollapsible(d.volume)
      # yValue: (d) -> y(d.percent)
      # yLabel: (d) -> app.formatters.percentTwoPlaces(d.percent)
    }
    


  # # refresh and format analysis data given current timeframe
  # prepareData: ->
  #   data = @reach.get @timeframe
  #   for periodId in @timeframe
  #     month = app.periods.get(periodId).month()
  #     for channelId, value of data[periodId]
  #       channel = app.channels.get(channelId).get('name')
  #       @table1Data.push channel: channel, period: month, value: value.actual
  #       @table2Data.push   channel: channel, period: month, value: value.plan
  #       if app.periods.get(periodId).notFuture
  #         @chartData.push  channel: channel, period: month, value: value.actual, class: 'actual'
  #       else
  #         @chartData.push  channel: channel, period: month, value: value.plan, class: 'plan'
    
  renderHeader: ->
    chartSelects = [
      {nodeId: 'stack', label: 'stacked'}
      {nodeId: 'group', label: 'grouped'}
    ]
    chartSelectsTemplate = JST['d3_chart/chart_selects']
    $('#main-chart-header').html chartSelectsTemplate(chartSelects: chartSelects)
    $('#group').on 'click', (event) => @mainChartView.transitionGroup()
    $('#stack').on 'click', (event) => @mainChartView.transitionStack()    

  # TODO pull dynamically!!!
  metricValue: ->
    app.formatters.intCommas(2092)
