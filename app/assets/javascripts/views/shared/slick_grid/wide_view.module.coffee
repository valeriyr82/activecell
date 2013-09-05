BaseView = require('views/shared/base_view')

module.exports = class SlickGridWideView extends BaseView
  template: JST['base_page/wide_table/wide_table']
  header: JST['base_page/wide_table/wide_table_header']
  footer: JST['base_page/wide_table/wide_table_footer']
  
  # instantiate the analytics module
  initialize: ->

  render: ->
    @$el.html @template
      # flags: @flagsStatus
    @renderHeaderFooter()
    @

  renderHeaderFooter: () ->
    @$('.wide-table-header').html @header
      # flags: @flagsStatus
    @$('.wide-table-footer').html @footer
      # flags: @flagsStatus
    @

  renderTable: (params, data, target) ->
    ReportGrid.pivotTable target,
      axes: params['axes']
      datapoints: data
      options: params['options']
