BaseView = require('views/shared/base_view')

module.exports = class TimeSliderView extends BaseView 
  template: JST['base_page/time_slider']
  
  initialize: (timeframe) ->
    @timeframe = timeframe
    
    mediator.on 'timeframe:change', (start, end) =>
      @timeframe = [start,end]
      @printMonths()
          
  render: =>
    @$el.html @template()
    @printMonths()
    @
  
  printMonths: ->
    massIds = app.periods.range(_.first(@timeframe), _.last(@timeframe))
    @$('#from').html app.periods.idToMonthYearString(_.first(massIds))
    @$('#to').html app.periods.idToMonthYearString(_.last(massIds))

  initializeSlider: =>
    @$('.time-slider').slider
      range: true
      min: app.periods.first().index()
      max: app.periods.last().index()
      values: [_.first(@timeframe), _.last(@timeframe)]
      slide: (event, ui) =>
        window.mediator.trigger('timeframe:change',
          ui.values[0]
          ui.values[1]
        )