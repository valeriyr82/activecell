ComingSoonView = require('views/shared/coming_soon_view')

module.exports = class CustomersIndexMRRView extends ComingSoonView

  # TODO pull dynamically!!!
  metricValue: ->
    app.formatters.usdCollapsible(3992038)
