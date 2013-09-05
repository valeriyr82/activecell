NestedDimensionView = require('views/shared/slick_grid/nested_dimension_view')

module.exports = class CompanyStagesView extends NestedDimensionView

  flagsStatus: 
    parentDimension: 'stage'
    childDimension: 'customer'
    allowAdd: true
    allowToggle: false

  events:
    'click .icon-small-cross' : 'deleteButtonClicked'

  initialize: ->
    super
    mediator.on 'slickdata:update', () =>
      if @groupItemMetadataProvider?
        @prepareSlickGridRows()
        @slick.dataView.beginUpdate()
        @slick.dataView.setItems(@slick.slickData)
        @sortDataView()
        @slick.dataView.endUpdate()
        @slick.dataView.refresh()
        @slick.gridSlick.updateRowCount()
        @slick.gridSlick.render()
        @initializeDnD()

  prepareSlickGridRows: ->
    @slick.slickData = {}
    @slick.slickData = for stage in app.stages.toJSON()
      id: stage.id
      name: stage.name
      lag_periods: stage.lag_periods
      position: stage.position
      stage_collection: stage
      stages_collection: app.stages
      main_dimension: 'customer'
      current_dimension: 'stage'

  row_metadata: (old_metadata_provider) ->
	  (row) ->
      item = @getItem(row)
      ret = old_metadata_provider(row)
      if item
        ret = ret or {}
        if item.name is "Customer"
          ret.cssClasses = (ret.cssClasses or "") + " independant"
          return ret
        ret.cssClasses = (ret.cssClasses or "") + " child id_" + item.id
      ret

  sortDataView: ->
    @slick.dataView.sort (a, b) ->
      b.position - a.position

  prepareSlickGridDataView: () ->
    super
    @sortDataView()
    

  prepareSlickGridColumns: ->
    @slickColumns = [
      {
        id: '#'
        name: ''
        behavior: "selectAndMove"
        cssClass: "cell-reorder dnd drag-button"
        resizable: false
        width: 30
        formatter: @dragButtonFormatter
      },
      {
        id: 'name'
        name: 'stage'
        field: 'name'
        editor: Slick.Editors.Text
      },
      {
        id: 'lag_periods'
        name: 'lag periods'
        field: 'lag_periods'
        formatter: @lagFormatter
        editor: Slick.Editors.Text
      },
      {
        id: 'editor'
        name: 'edit'
        field: 'edit'
        cssClass: 'align-right'
        headerCssClass: 'align-right'
        formatter: @deleteButtonFormatter
      }
    ]

  lagFormatter: (row, cell, value, columnDef, dataContext) ->
    nextStage = app.stages.find((item)->
      item.get('position') is dataContext.position - 1)
    if dataContext.name isnt 'Customer' and nextStage?
      switch value
        when 0 
          "becomes a #{nextStage.get('name')} the same month"
        when 1
          "1 month to become a #{nextStage.get('name')}"
        else
          "#{value} months to become a #{nextStage.get('name')}"
        
  deleteButtonFormatter: (row, cell, value, columnDef, dataContext) ->
    if dataContext.name isnt 'Customer'
      "<i class='icon-small-cross icon-grey'></i>"

  dragButtonFormatter: (row, cell, value, columnDef, dataContext) ->
    if dataContext.name isnt 'Customer'
      "<i class='icon-small-align-center icon-grey'></i>"

  subscribeTableEvents: () ->
    super
    @slick.gridSlick.onBeforeEditCell.subscribe (e, args) ->
      if args.item.name is 'Customer'
        return false
      true

    @slick.gridSlick.onCellChange.subscribe (e, args) ->
      stage =  app.stages.get(args.item.id)
      if stage
        stage.save { name : args.item.name, lag_periods: args.item.lag_periods }
        window.mediator.trigger('slickdata:update')

  addDimension: (text, widget) =>
    app.stages.create(
      {
        name : text
        lag_periods : 0
        position : app.stages.length + 1
      }
      { success: -> 
          window.mediator.trigger('slickdata:update')
      }
    )
    super

#  _onMoveRowsChild: (e, {insertBefore, rows}, {_gridSlick, group}) ->
#    model = []
#    curDim = @slick.slickData[0].current_dimension
#    if curDim
#      _gridSlick.getDataItem(rows[0])[curDim] = group.value
#      _gridSlick.getDataItem(rows[0])[curDim + '_id'] = group.id if group.id
#    model = app.customers.find((item) ->
#     item.id is _gridSlick.getDataItem(rows[0])['id']
#    )
#    if model
#      model.save { channel_id : group.id , channel : app.channels.get(group.id).toJSON()}
#    @slick.dataView.refresh()
#    @slick.gridSlick.render()
 
  metricValue: ->
    app.formatters.intCollapsible(app.channels.length)
    
  deleteButtonClicked: (e) ->
    # the required row has a class id_... with id of a stage, so we get this id 
    regExp = /id_([^\s]+)/i
    idString = regExp.exec($(e.target.parentElement.parentElement).attr('class'))[0].substring(3)
    stage = app.stages.get(idString)
    if stage
      stage.destroy()
      window.mediator.trigger('slickdata:update')

  _onBeforeMoveRows: (e, {insertBefore, rows}) ->
    len = @slick.gridSlick.getData().getItems().length
    # prevent drop if we trying to drop out of the table or to the current place
    if insertBefore is len or insertBefore is rows[0] or insertBefore is rows[0] + 1
      e.stopPropagation()
      return false
    # prevent drop if we trying to drap Customer line
    if @slick.gridSlick.getDataItem(rows[0]).name is 'Customer'
      e.stopPropagation()
      return false
    true

  _onMoveRows: (e, args) ->
    {gridSlick, dataView} = @slick
    _gridSlick = @slick.gridSlick
    _dataView = @slick.dataView
    _gridData = _gridSlick.getData()
    items = _gridData.getItems()
    extractedRows = []
    left = undefined
    right = undefined
    rows = args.rows
    insertBefore = args.insertBefore
    left = items.slice(0, insertBefore)
    right = items.slice(insertBefore, items.length)
    rows.sort (a, b) ->
      b.position - a.position
    i = 0
    while i < rows.length
      extractedRows.push items[rows[i]]
      i++
    rows.reverse()
    i = 0
    while i < rows.length
      row = rows[i]
      if row < insertBefore
        left.splice row, 1
      else
        right.splice row - insertBefore, 1
      i++

    stage = app.stages.get(_gridSlick.getDataItem(args.rows[0]).id)
    if stage
      stage.save { position : Math.floor(Math.random() * 1000000000) }
    if insertBefore < args.rows[0]
      mass = [insertBefore..(args.rows[0] - 1)]
      mass.reverse()
      for index in mass
        model = app.stages.get(_gridSlick.getDataItem(index).id)
        if model
          model.save { position : (model.get('position') - 1) }
      newPos = items.length - insertBefore
    else
      mass = [(args.rows[0] + 1)..(insertBefore-1)]
      for index in mass
        model = app.stages.get(_gridSlick.getDataItem(index).id)
        if model
          model.save { position : (model.get('position') + 1) }
      newPos = items.length - insertBefore + 1
    if stage
      stage.save { position : newPos }

    _gridData = left.concat(extractedRows.concat(right))
    args = arguments
    Array::push.call(args, {_gridSlick: gridSlick, group: []})
    @_onMoveRowsChild && @_onMoveRowsChild.apply(@, args)
    window.mediator.trigger('slickdata:update')
