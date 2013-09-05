Conversion = require('analysis/conversion')
ComingSoonView = require('views/shared/coming_soon_view')

module.exports = class ChannelsShowConversionView extends ComingSoonView
  template: JST['base_page/base_page']

  chartTitle:         'conversion'
  chartSubtitle:      ''
  timeFrameDesc:      'trailing 5 months, current month, coming 6 months'

  initialize: ->
    @availableTimeframe = app.periods.range(-18, 36)
    @conversion         = new Conversion()

  renderMain: ->
    @timeframe = app.periods.range(-5, 6)
    @data      = @conversion.get @timeframe

  # TODO pull dynamically!!!
  metricValue: ->
    app.formatters.percentTwoPlaces(0.1293234)
