SlickGridView = require('views/shared/slick_grid/slick_grid_view')

module.exports = class NestedDimensionView extends SlickGridView

  template: JST['base_page/nested_dimension/nested_dimension']
  header: JST['base_page/nested_dimension/nested_dimension_header']
  footer: JST['base_page/nested_dimension/nested_dimension_footer']

  events:
    'click .btn-add-dimension'          : 'addClicked'
    'keypress .text-add-dimension'      : 'addClicked'
    'keyup .air-search > .filter-list'  : 'filterTable'

  initialize: ->
    super
    $.extend true, @, @options

  miniChartOptions: ->
    return {
      type: 'spark line'
      data: [5,4,5,5,6,6,5,5,5,4,4,5]
    }

  metricValue: ->
    app.formatters.intCommas(Math.random() * 1000) + 'km'

  row_metadata: (old_metadata_provider) ->
    (row) ->
      item = @getItem(row)
      ret = old_metadata_provider(row)
      if item
        ret = ret or {}
        if item.__group
          ret.cssClasses = (ret.cssClasses or "") + " parent"
        else
          ret.cssClasses = (ret.cssClasses or "") + " child"
      ret
