NestedDimensionView = require('views/shared/slick_grid/nested_dimension_view')

module.exports = class ChannelsIndexListView extends NestedDimensionView

  flagsStatus: 
    parentDimension: 'channel'
    childDimension: 'customer'
    selectDimension: 'segment'
    allowAdd: true
    allowToggle: false
     
  # define main table column characteristics
  initialize: ->
    super

  # define main table data to be displayed
  prepareSlickGridRows: ->
    super
    @slick.slickData = for customer in app.customers.toJSON()
      id: customer.id
      name: customer.name
      channel: customer.channel.name
      segment: customer.segment.name
      segment_id: customer.segment.id
      channel_id: customer.channel.id
      segment_collection: app.segments
      channels_collection: app.channels
      main_dimension: 'customer'
      current_dimension: 'channel'
      revenue: app.formatters.usdCollapsible app.customers.
        get(customer.id).trailing12mRevenue()

  # define what to show for metric in analysis nav
  metricValue: ->
    app.formatters.intCollapsible(app.channels.length)

  # define what to show for mini-chart view in analysis nav
#  miniChartOptions: ->
  prepareSlickGridDataView: ->
    super
    @groupTableItems 'channel'
    groups = @slick.dataView.getGroups()
    for group in groups
      @slick.dataView.collapseGroup(group.value)


  prepareSlickGridColumns: ->
    super
    @slickColumns = [
      {
        id: 'name'
        name: 'customer'
        field: 'name'
        behavior: "selectAndMove"
        cssClass: "cell-reorder dnd"
      },
      {
        id: 'segment'
        name: 'segment'
        field: 'segment'
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


  # define main table event handling behaviors 
  subscribeTableEvents: () ->
    super
    @slick.gridSlick.onCellChange.subscribe (e, args) ->
      dimension = []
      customer =  app.customers.get(args.item.id)
      if customer
        dimension = app.segments.get(this.getCellNode(args.row, args.cell).id)
        customer.save { segment_id : dimension.id, segment : dimension.toJSON()} if dimension
        args.item.segment_id = dimension.id

  # define event handling for dimension add
  addDimension: (text, widget) =>
    app.channels.create { name : text }
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
      model.save { channel_id : group.id , channel : app.channels.get(group.id).toJSON()}
    @slick.dataView.refresh()
    @slick.gridSlick.render()