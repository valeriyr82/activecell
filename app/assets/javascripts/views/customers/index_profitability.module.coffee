ComingSoonView = require('views/shared/coming_soon_view')

module.exports = class CustomersIndexProfitabilityView extends ComingSoonView
  
  # TODO pull dynamically!!!
  metricValue: ->
    app.formatters.percentTwoPlacesCommas(0.245423)
