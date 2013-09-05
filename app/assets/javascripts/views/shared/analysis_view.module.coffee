BaseView = require('views/shared/base_view')
TimeSliderView  = require('views/shared/time_slider_view')

module.exports = class AnalysisView extends BaseView
  template: JST['base_page/base_page']
  # TODO move parse somewhere more logical
  parse: d3.time.format("%Y-%m-%d").parse
    
  # instantiate the analytics module
  initialize: ->
    periods = app.periods
    @availableTimeframe = app.periods.pluck('id')
    @timeframe          = [periods.first().index(), periods.last().index()]
    @data               = []
    @slick  = []
  
  renderMain: ->

  miniChartOptions: ->
    switch Math.round(Math.random())
      when 0
        {
          type: 'spark line'
          data: [1,2,3,2,3,4,3,4,5,4,5,6,5,6,7,6,7,8]
        }
      when 1
        {
          id: 'reach'
          type: 'column'
          data: [
              {"label":"FL", "val":30000 }
              {"label":"CA", "val":20000 }
              {"label":"NY", "val":30000 }
              {"label":"NC", "val":40000 }
              {"label":"SC", "val":50000 }
              {"label":"AZ", "val":60000 }
            ]
        }

  dashboardOptions: -> null

  metricValue: ->
    app.formatters.intCommas(Math.random() * 1000) + 'km'

  renderTimeSlider: ->
    view = @createView TimeSliderView, @timeframe
    @$('#time-slider-container').html view.render().el
    view.initializeSlider()
