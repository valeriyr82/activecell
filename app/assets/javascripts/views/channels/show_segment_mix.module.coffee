ComingSoonView = require('views/shared/coming_soon_view')

module.exports = class ChannelsShowSegmentMixView extends ComingSoonView

  # TODO pull dynamically!!!
  metricValue: ->
    app.formatters.percentTwoPlacesCommas(.14225)
