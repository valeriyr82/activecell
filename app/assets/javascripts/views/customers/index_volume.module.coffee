ComingSoonView = require('views/shared/coming_soon_view')

module.exports = class CustomersIndexVolumeView extends ComingSoonView
  
  # TODO pull dynamically!!!
  metricValue: ->
    app.formatters.intCollapsible(82)
    
  dashboardOptions: ->
    {
      type: 'leaderboard'
      data: [
        { label: 'USA', value: 0.745, change: 0.23 },
        { label: 'New Zealand', value: 0.457, change: -0.12 },
        { label: 'Australia', value: 0.64, change: 0.16 }
      ]
    }
