AnalysisView = require('views/shared/analysis_view')
UpperChartView = require('views/shared/d3_chart/upper_view')

module.exports = class ChannelsIndexConversionView extends AnalysisView

  renderMain: ->
    @prepareData()
    @renderChart()

  # refresh the data to reflect any changes
  prepareData: ->
    @data =
      [
        {key: 'Customer', value: 0.20, date: '04/23/12'}
        {key: 'Prospect', value: 0.63, date: '04/23/12'}
        {key: 'Lead'    , value: 0.17, date: '04/23/12'}
        {key: 'Customer', value: 0.25, date: '04/24/12'}
        {key: 'Prospect', value: 0.57, date: '04/24/12'}
        {key: 'Lead'    , value: 0.18, date: '04/24/12'}
        {key: 'Customer', value: 0.35, date: '04/25/12'}
        {key: 'Prospect', value: 0.46, date: '04/25/12'}
        {key: 'Lead'    , value: 0.19, date: '04/25/12'}
        {key: 'Customer', value: 0.40, date: '04/26/12'}
        {key: 'Prospect', value: 0.40, date: '04/26/12'}
        {key: 'Lead'    , value: 0.20, date: '04/26/12'}
      ]
      
    format = d3.time.format("%m/%d/%y")
    @data.forEach (d) ->
      d.date = format.parse(d.date)
      d.value = +d.value

  renderChart: ->
    @mainChartView = @createView UpperChartView, @data
    @$('#main_chart').html @mainChartView.render().el
    
    # define scales and axes (note inverted domain for y-scale: bigger is up!),
    #   including the (required) update function that the chart can use
    x = d3.time.scale()
    y = d3.scale.linear()
    z = d3.scale.category20c()
    @mainChartView.axes['xAxis'] = d3.svg.axis().scale(x).ticks(d3.time.days)
    @mainChartView.axes['yAxis'] = d3.svg.axis().scale(y).ticks(4).orient("left")

    # axes['update'] is a function used to recalculate dynamic axes by
    #   computing the desired x-axis range and the maximum y value.
    @mainChartView.axes['update'] = () =>
      x.domain d3.extent(@data, (d) -> d.date)
      y.domain [0, d3.max(@data, (d) -> d.y0 + d.y)]
    @mainChartView.axes['update']() # set initial timeframe

    # define series
    @mainChartView.series.push {
      id: 'conversion'
      type: 'stacked area'
      title: 'conversion'
      xStack: (d) -> d.date
      xValue: (d) -> x(d.date)
      yStack: (d) -> d.value
      y0Value: (d) -> y(d.y0)
      y1Value: (d) -> y(d.y0 + d.y)
    }

  # TODO pull dynamically!!!
  metricValue: ->
    app.formatters.percentTwoPlaces(0.178234)
