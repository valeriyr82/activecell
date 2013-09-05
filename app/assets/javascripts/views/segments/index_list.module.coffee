NestedDimensionView = require('views/shared/slick_grid/nested_dimension_view')

module.exports = class SegmentIndexListView extends NestedDimensionView
  flagsStatus: 
    parentDimension: 'segment'
    childDimension: 'customer'
    selectDimension: 'channel'
    allowAdd: true
    allowToggle: false
    
  initialize: ->
    super
    _.extend @events, NestedDimensionView::events
    _.extend @flagsStatus, NestedDimensionView::flagsStatus


  prepareSlickGridRows: ->
    @slick.slickData or= {}
    @slick.slickData = for customer in app.customers.toJSON()
      id: customer.id
      name: customer.name
      channel: customer.channel.name
      segment: customer.segment.name
      segment_id: customer.segment.id
      channel_id: customer.channel.id
      segment_collection: app.segments
      channels_collection: app.channels
      current_dimension: 'segment'
      revenue: app.formatters.usdCollapsible app.customers.
        get(customer.id).trailing12mRevenue()


  prepareSlickGridColumns: ->
    @slickColumns = [
      {
        id: 'name'
        name: 'customer'
        field: 'name'
        behavior: "selectAndMove"
        cssClass: "cell-reorder dnd"
      },
      {
        id: 'channel'
        name: 'channel'
        field: 'channel'
        editor: Slick.Editors.Select
        formatter: Slick.Formatters.EditableCell
      },
      {
        id: 'revenue-12mt'
        name: 'revenue (trailing 12m)'
        field: 'revenue'
        cssClass: 'align-right'
        headerCssClass: 'align-right'
      }
    ]

  prepareSlickGridDataView: () ->
    super
    @groupTableItems 'segment'
    groups = @slick.dataView.getGroups()
    for group in groups
      @slick.dataView.collapseGroup(group.value)

  subscribeTableEvents: () ->
    super
    @slick.gridSlick.onCellChange.subscribe (e, args) ->
      dimension = []
      customer =  app.customers.get(args.item.id)
      if customer
        dimension = app.channels.get(this.getCellNode(args.row, args.cell).id)
        customer.save { channel_id : dimension.id, channel : dimension.toJSON()} if dimension
        args.item.channel_id = dimension.id

  addDimension: (text, widget) =>
    app.segments.create { name : text }
    super

  _onMoveRowsChild: (e, {insertBefore, rows}, {_gridSlick, group}) ->
    model = []
    curDim = @slick.slickData[0].current_dimension

    if curDim
      _gridSlick.getDataItem(rows[0])[curDim] = group.value
      _gridSlick.getDataItem(rows[0])[curDim + '_id'] = group.id if group.id
      model = app.customers.find((item) ->
        item.id is _gridSlick.getDataItem(rows[0])['id']
      )
      if model
        curDim = @slick.slickData[0].current_dimension
        model.save { segment_id : group.id , segment : app.segments.get(group.id).toJSON()}

    @slick.dataView.refresh()
    @slick.gridSlick.render()
