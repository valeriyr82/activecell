NestedDimensionView = require('views/shared/slick_grid/nested_dimension_view')

module.exports = class VendorsIndexListView extends NestedDimensionView
  flagsStatus: 
    allowAdd: false
    allowToggle: false

  initialize: ->
    super

  prepareSlickGridRows: ->
    @slick.slickData or= {}
    @slick.slickData = for vendor in app.vendors.toJSON()
      id: vendor.id
      name: vendor.name
      expense: app.formatters.usdCollapsible app.vendors.
        get(vendor.id).trailing12mSpend()

  prepareSlickGridColumns: ->
    @slickColumns = [
      {
        id: 'name'
        name: 'vendor'
        field: 'name'
      },
      {
        id: 'expense-12mt'
        name: 'expense (trailing 12m)'
        field: 'expense'
        cssClass: 'align-right'
        headerCssClass: 'align-right'
      }
    ]
