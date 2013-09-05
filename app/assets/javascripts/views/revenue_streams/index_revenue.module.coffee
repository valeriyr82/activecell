ComingSoonView = require('views/shared/coming_soon_view')
# actived3 = require('views/shared/d3_chart/actived3')

module.exports = class RevenueStreamsIndexRevenueView extends ComingSoonView

  # instantiate something
  initialize: ->
    super
    
  # refresh and format analysis data given current timeframe
  prepareData: ->
    @chartdata = [
      { label: 'USA', value: 0.745, change: 0.23 },
      { label: 'New Zealand', value: 0.457, change: -0.12 },
      { label: 'Australia', value: 0.64, change: 0.16 }
    ]
      
  renderMain: ->
    @prepareData()
    @renderChart()

  renderChart: ->
    options =
      width: 400
      height: 200
      padding: [50, 50, 50, 50]
      barlength: 250
