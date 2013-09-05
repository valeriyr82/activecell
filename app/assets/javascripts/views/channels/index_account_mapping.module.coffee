NestedDimensionView = require('views/shared/slick_grid/nested_dimension_view')

module.exports = class ChannelsIndexAccountMappingView extends NestedDimensionView
  flagsStatus: 
    parentDimension: 'channel'
    childDimension: 'account'
    allowToggle: false

  initialize: ->
    super
    _.extend @events, NestedDimensionView::events
    _.extend @flagsStatus, NestedDimensionView::flagsStatus

  prepareSlickGridRows: ->
    super
    for account in app.accounts.toJSON()
      if account.activecell_category is "sales & marketing"
        if account.channel_id is null
          account.set(channel_id: app.channels.defaultId())
        @slick.slickData.push
          id: account.id
          name: account.name
          channel: app.channels.get(account.channel_id).get('name')
          channel_id: account.channel_id
          main_dimension: 'account'
          current_dimension: 'channel'
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
        id: 'spend-12mt'
        name: 'spend (12 month trailing)'
        field: 'spend'
        cssClass: 'align-right'
        headerCssClass: 'align-right'
      }
    ]

  addDimension: (text, widget) =>
    app.channels.create { name : text }
    super

  _onMoveRowsChild: (e, {insertBefore, rows}, {_gridSlick, group}) ->
    model = []
    curDim = @slick.slickData[0].current_dimension
    mainDim = @slick.slickData[0].main_dimension
    if curDim
      _gridSlick.getDataItem(rows[0])[curDim] = group.value
      _gridSlick.getDataItem(rows[0])[curDim + '_id'] = group.id if group.id
      model = app.accounts.find((item) ->
        item.id is _gridSlick.getDataItem(rows[0])['id']
      )
      if model
        model.save { channel_id : group.id , channel : app.channels.get(group.id).toJSON()}

    @slick.dataView.refresh()
    @slick.gridSlick.render()
    
  # TODO pull dynamically!!!
  metricValue: ->
    '--'
