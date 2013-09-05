D3ChartView = require('views/shared/d3_chart/d3_chart_view')

module.exports = class D3ChartUpperView extends D3ChartView 
  template: JST['base_page/main_chart/main_chart']
  header: JST['base_page/main_chart/main_chart_header']
  footer: JST['base_page/main_chart/main_chart_footer']
  
  # instantiate the analytics module
  initialize: (data) ->
    super
    @target = '#main-d3-chart'
    @margin = {top: 30, right: 30, bottom: 30, left: 30}
    @legend = true
      
  renderHeaderFooter: () ->
    @$('.main-chart-header').html @header
    @$('.main-chart-footer').html @footer
    @