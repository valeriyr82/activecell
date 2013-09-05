D3ChartView = require('views/shared/d3_chart/d3_chart_view')

module.exports = class D3ChartMiniView extends D3ChartView 
  template: JST['d3_chart/mini']
  
  # instantiate the analytics module
  initialize: (options) ->
    super
    @data = options.data
    color = if options.color? then options.color else '#30878F' # TODO remove hardcoded colors
    tooltip = if options.toolip? then options.toolip else (d) -> "#{d.label}: #{d.val}"
    @series.push 
      type: options.type
      color: color
      tooltip: tooltip
      id: "mini-#{options.id}"
    @margin = options.margin || {top: 1, right: 1, bottom: 1, left: 1}
    @target = ".mini-chart-container"
    @legend = false
  
  renderHeaderFooter: () ->
    
