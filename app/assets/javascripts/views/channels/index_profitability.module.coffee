AnalysisView = require('views/shared/analysis_view')
UpperChartView  = require('views/shared/d3_chart/upper_view')

module.exports = class ChannelsIndexProfitabilityView extends AnalysisView
  # instantiate the analytics module and set the initial analysis timeframe
  initialize: ->
    super
    [@tableData, @chartData]  = [[],[]]
  
  renderMain: ->
    @prepareData()
    @renderChart()
    
  # refresh and format analysis data given current timeframe
  prepareData: ->
    for num in [1..50]
      obj = {}
      obj.volume = Math.floor(Math.random()*100000)
      if num % 2 is 0
        obj.percent = Math.random()
        if obj.volume >= 50000
          obj.category = 'stars'
        else
          obj.category = 'sprouts'
      else
        obj.percent = -Math.random()
        if obj.volume >= 50000
          obj.category = 'dogs'
        else
          obj.category = 'noise'
      @data.push(obj)

  renderChart: ->
    @mainChartView = @createView UpperChartView, @data
    @$('#main_chart').html @mainChartView.render().el
    
    # define scales and axes (note inverted domain for y-scale: bigger is up!),
    #   including the (required) update function that the chart can use
    x = d3.scale.linear().domain([0, d3.max(@data, (d) -> return d.volume )])
    y = d3.scale.linear().domain([-1,1]) # not true. todo: calculate lower y extent below
    @mainChartView.axes['xAxis'] = d3.svg.axis().scale(x).ticks(4)
    @mainChartView.axes['yAxis'] = d3.svg.axis().scale(y).ticks(4).orient("left")
    
    # axes['update'] is a function used to recalculate dynamic axes by
    #   computing the desired x-axis range and the maximum y value.
    @mainChartView.axes['update'] = () =>
      domainX = d3.extent((d.volume for d in @data))
      xScale = d3.scale.linear().domain(domainX)
      # todo: calculate lower y extent
    @mainChartView.axes['update']() # set initial domains
    
    @mainChartView.series.push {
      id: 'scatter'
      type: 'scatter'
      category: (d) -> d.category
      xValue: (d) -> x(d.volume)
      xLabel: (d) -> app.formatters.usdCollapsible(d.volume)
      yValue: (d) -> y(d.percent)
      yLabel: (d) -> app.formatters.percentTwoPlaces(d.percent)
    }

  # TODO pull dynamically!!!
  metricValue: ->
    app.formatters.percentTwoPlacesCommas(0.345423)
