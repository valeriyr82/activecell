NestedDimensionView = require('views/shared/slick_grid/nested_dimension_view')

module.exports = class CustomersIndexListView extends NestedDimensionView
  flagsStatus: 
    dimension: 'customer'
    parentDimension: 'segment'
    childDimension: 'customer'
    selectDimension: 'channel'
    allowAdd: true
    allowToggle: true

  events:
    'click #toggle-view-button > .btn' : 'toggleClicked'

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
      main_dimension: 'customer'
      current_dimension: 'segment'
      revenue: app.formatters.usdCollapsible app.customers.
        get(customer.id).trailing12mRevenue()

  editableCellFormatter: (row, cell, value, columnDef, dataContext) ->
    return "<div class='editable-cell'><span>" + value + "</span><i class='icon-small-pencil'></i></div>"

  prepareSlickGridColumns: ->
    _.defaults(Slick.Formatters, {'EditableCell' : @editableCellFormatter});
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

  subscribeTableEvents: () ->
    super
    @slick.gridSlick.onCellChange.subscribe (e, args) ->
      dimension = []
      customer =  app.customers.get(args.item.id)
      if customer
        curDim = args.item.current_dimension
        if curDim is 'segment'
          dimension = app.channels.get(@getCellNode(args.row, args.cell).id)
          customer.save { channel_id : dimension.id, channel : dimension.toJSON()} if dimension
          args.item.channel_id = dimension.id
        else if curDim is 'channel'
          dimension = app.segments.get(@getCellNode(args.row, args.cell).id)
          customer.save { segment_id : dimension.id, segment : dimension.toJSON()} if dimension
          args.item.segment_id = dimension.id

  toggleClicked: (e) =>
    dimension = ''
    select_dimension = ''
    if e.target.id is 'btn-view-channel'
      dimension = 'segment'
      select_dimension = 'channel'
    else if e.target.id is 'btn-view-segment'
      dimension = 'channel'
      select_dimension = 'segment'
    @slickColumns[1].id = dimension
    @slickColumns[1].name = dimension
    @slickColumns[1].field = dimension
    for item in @slick.slickData
      item.current_dimension = select_dimension
    @flagsStatus.selectDimension = dimension
    @flagsStatus.parentDimension = select_dimension
    @flagsStatus.addBtn = false
    @groupTableItems select_dimension
    @renderHeaderFooter()
    @slick.gridSlick.setColumns @slickColumns
    @slick.gridSlick.render()

  addDimension: (text, widget) =>
    curDim = @slick.slickData[0].current_dimension
    if curDim is 'segment'
      app.segments.create { name : text }
    else if curDim is 'channel'
      app.channels.create { name : text }
    super

  _onMoveRowsChild: (e, {insertBefore, rows}, {_gridSlick, group}) ->
    model = []
    curDim = @slick.slickData[0].current_dimension
    mainDim = @slick.slickData[0].main_dimension
    
    if curDim
      _gridSlick.getDataItem(rows[0])[curDim] = group.value
      _gridSlick.getDataItem(rows[0])[curDim + '_id'] = group.id if group.id
      model = app.customers.find((item) ->
        item.id is _gridSlick.getDataItem(rows[0])['id']
      )
      if model
        curDim = @slick.slickData[0].current_dimension
        switch curDim
          when 'segment'
            model.save { segment_id : group.id , segment : app.segments.get(group.id).toJSON()}
          when 'channel'
            model.save { channel_id : group.id , channel : app.channels.get(group.id).toJSON()}

    @slick.dataView.refresh()
    @slick.gridSlick.render()
  
  metricValue: ->
    app.formatters.intCollapsible(app.customers.length)
