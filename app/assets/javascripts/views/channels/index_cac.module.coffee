ComingSoonView = require('views/shared/coming_soon_view')

module.exports = class ChannelsIndexCACView extends ComingSoonView
  
  # TODO pull dynamically!!!
  metricValue: ->
    value = 912.845423
    if value <1000
      app.formatters.usdTwoPlaces(value)
    else
      app.formatters.usdCollapsible(value)
