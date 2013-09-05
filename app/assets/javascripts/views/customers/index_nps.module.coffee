AnalysisView    = require('views/shared/analysis_view')
UpperChartView  = require('views/shared/d3_chart/upper_view')

module.exports = class CustomersIndexNPSView extends AnalysisView

  initialize: ->
    super

  renderMain: ->
    @data = [-10, 1, 10]
    @renderChart()

  dashboardOptions: ->
    {
      type: 'gauge'
      data: [-10, 1, 10]
    }
    
  miniChartOptions: ->
    {
      type: 'gauge'
      data: [-10, 1, 10]
      tooltip: 1
    } 

  renderChart: ->
    @mainChartView = @createView UpperChartView, @data
    @$('#main_chart').html @mainChartView.render().el
    
    # define series
    @mainChartView.series.push {
      type: 'gauge'
      title: 'net promoter score'
    }

  # TODO pull dynamically!!!
  metricValue: ->
    app.formatters.twoPlacesCommas(5.79343)
