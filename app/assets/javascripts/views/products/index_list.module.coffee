NestedDimensionView = require('views/shared/slick_grid/nested_dimension_view')

module.exports = class ProductsIndexListView extends NestedDimensionView
  flagsStatus:
    allowAdd: false
    allowToggle: false

  initialize: ->
    super

  prepareSlickGridRows: ->
    @slick.slickData or= {}
    @slick.slickData = for product in app.products.toJSON()
      id: product.id
      name: product.name
      revenue_collection: app.products
      revenue: app.formatters.usdCollapsible app.products.
        get(product.id).trailing12mRevenue()

  prepareSlickGridColumns: ->
    @slickColumns = [
      {
        id: 'name'
        name: 'product'
        field: 'name'
      },
      {
        id: 'revenue-12mt'
        name: 'revenue (trailing 12m)'
        field: 'revenue'
        cssClass: 'align-right'
        headerCssClass: 'align-right'
      }
    ]
