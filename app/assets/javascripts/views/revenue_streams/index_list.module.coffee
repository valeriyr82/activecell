NestedDimensionView = require('views/shared/slick_grid/nested_dimension_view')

module.exports = class RevenueStreamsIndexListView extends NestedDimensionView
  flagsStatus: 
    allowAdd: false
    allowToggle: false

  initialize: ->
    super
    _.extend @events, NestedDimensionView::events
    _.extend @flagsStatus, NestedDimensionView::flagsStatus

  prepareSlickGridRows: ->
    @slick.slickData or= []
    for account in app.accounts.toJSON()
      if app.accounts.get(account.id).isRevenue()
        @slick.slickData.push
          id: account.id
          name: account.name
          revenue_stream: app.revenueStreams.get(account.revenue_stream_id).get('name')
          revenue_stream_id: account.revenue_stream_id
          revenue_stream_collection: app.revenueStreams
          revenue: app.formatters.usdCollapsible app.accounts.
            get(account.id).trailing12mRevenue()
          main_dimension: 'account'
          current_dimension: 'revenue_stream'

  prepareSlickGridDataView: () ->
    super
    @groupTableItems 'revenue_stream'
    groups = @slick.dataView.getGroups()
    for group in groups
      @slick.dataView.collapseGroup(group.value)

  prepareSlickGridColumns: ->
    @slickColumns = [
      {
        id: 'name'
        name: 'account'
        field: 'name'
        behavior: "selectAndMove"
        cssClass: "cell-reorder dnd"
      },
      {
        id: 'revenue-12t'
        name: 'revenue (trailing 12m)'
        field: 'revenue'
        cssClass: 'align-right'
        headerCssClass: 'align-right'
      }
    ]

  _onMoveRowsChild: (e, {insertBefore, rows}, {_gridSlick, group}) ->
    model = []
    curDim = @slick.slickData[0].current_dimension

    if curDim
      _gridSlick.getDataItem(rows[0])['activecell_category'] = group.value
      _gridSlick.getDataItem(rows[0])[curDim + '_id'] = group.id if group.id
      model = app.accounts.find((item) ->
        item.id is _gridSlick.getDataItem(rows[0])['id']
      )
      if model
        model.save { revenue_stream_id : group.id , revenue_stream : app.revenueStreams.get(group.id).toJSON()}

    @slick.dataView.refresh()
    @slick.gridSlick.render()
