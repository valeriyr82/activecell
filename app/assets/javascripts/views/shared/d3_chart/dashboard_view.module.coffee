D3ChartView = require('views/shared/d3_chart/d3_chart_view')

module.exports = class D3ChartDashboardView extends D3ChartView 
  template: JST['d3_chart/dashboard']
  header: JST['dashboard/metric/header']
  
  # instantiate the analytics module
  initialize: (options) ->
    super
    @data = options.data
    @name = options.name
    @analysisId = options.analysisId
    @analysisCategory = options.analysisCategory
    tooltip = if options.toolip? then options.toolip else (d) -> "#{d.label}: #{d.val}"
    @series.push
      type: options.type
      xValue: options.xValue
      yValue: options.yValue
      id: @id
      tooltip: tooltip
      includeLabels: if options.type is 'gauge' then true else false
    @margin = options.margin || {top: 10, right: 10, bottom: 10, left: 10}
    @target = ".metric-inner-container"
    @legend = false
  
  renderHeaderFooter: () ->    
    @$('.metric-header').html @header
      name: @name
      link: "##{@analysisCategory}/#{@analysisId}"
