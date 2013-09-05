RevenueStream = require('models/revenue_stream')

module.exports = class RevenueStreams extends Backbone.Collection
  url: 'api/v1/revenue_streams'
  model: RevenueStream

  isUsed: (name) ->
    @where(name: name).length > 0
