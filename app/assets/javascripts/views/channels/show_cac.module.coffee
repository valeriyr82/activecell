ComingSoonView = require('views/shared/coming_soon_view')

module.exports = class ChannelsShowCACView extends ComingSoonView
  
  # TODO pull dynamically!!!
  metricValue: ->
    value = 22.845423
    if value <1000
      app.formatters.usdTwoPlaces(value)
    else
      app.formatters.usdCollapsible(value)
