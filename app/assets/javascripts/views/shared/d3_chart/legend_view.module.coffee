BaseView = require('views/shared/base_view')

module.exports = class D3LegendView extends BaseView 
  legendItemTemplate: JST['base_page/main_chart/main_chart_legend_item']
  tagName: 'ul'
  className: 'chart-legend'
  
  initialize: (options) ->
    @series = options.series
    
  render: =>
    for series in @series
      @$el.append(@legendItemTemplate(series: series))
    @
