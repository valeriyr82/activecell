BaseView        = require('views/shared/base_view')

module.exports = class SlickGridUpperView extends BaseView

  # instantiate the analytics module
  initialize: ->

  renderTable: (params, data, target) ->
    ReportGrid.pivotTable target,
      axes: params['axes']
      datapoints: data
      options: params['options']