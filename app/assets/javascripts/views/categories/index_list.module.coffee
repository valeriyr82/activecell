NestedDimensionView = require('views/shared/slick_grid/nested_dimension_view')

module.exports = class CategoriesIndexListView extends NestedDimensionView

  flagsStatus: 
    parentDimension: 'category'
    childDimension: 'account'
    allowAdd: true
    allowToggle: false

    
  initialize: ->
    super
    _.extend @events, NestedDimensionView::events
    _.extend @flagsStatus, NestedDimensionView::flagsStatus

  prepareSlickGridRows: ->
    super
    @slick.slickData or= []
    for account in app.accounts.toJSON()
      if account.activecell_category is 'other'
        if account.category_id is null
          app.accounts.get(account.id).set({category_id: app.categories.defaultId()})
        @slick.slickData.push
          id: account.id
          name: account.name
          category: app.categories.get(account.category_id).get('name')
          category_id: account.category_id
          main_dimension: 'account'
          current_dimension: 'category'
          spend: app.formatters.usdCollapsible app.accounts.
            get(account.id).trailing12mSpend()

  prepareSlickGridColumns: ->
    super
    @slickColumns = [
      {
        id: 'name'
        name: 'account'
        field: 'name'
        behavior: "selectAndMove"
        cssClass: "cell-reorder dnd"
      },
      {
        id: 'spend-12m'
        name: 'spend (trailing 12m)'
        field: 'spend'
        cssClass: 'align-right'
        headerCssClass: 'align-right'
      }
    ]

  prepareSlickGridDataView: () ->
    super
    @groupTableItems 'category'
    groups = @slick.dataView.getGroups()
    for group in groups
      @slick.dataView.collapseGroup(group.value)

  _onMoveRowsChild: (e, {insertBefore, rows}, {_gridSlick, group}) ->
    model = []
    curDim = @slick.slickData[0].current_dimension
    mainDim = @slick.slickData[0].main_dimension

    if curDim
      _gridSlick.getDataItem(rows[0])[curDim] = group.value
      _gridSlick.getDataItem(rows[0])[curDim + '_id'] = group.id if group.id
      model = app.accounts.find((item) =>
        item.id is @slick.getDataItem(rows[0])['id']
      )
      
      model.set { category_id : group.id } if model

    @slick.dataView.refresh()
    @slick.gridSlick.render()
