require('views/shared/slick_grid/slick/slick')
BaseView = require('views/shared/base_view')
SearchBoxView = require('views/shared/search_box')
SlickGridSlider = require('views/shared/slick_grid_slider')

module.exports = class SlickGridView extends BaseView

  _.extend(@::, SlickGridSlider)

  defaults: {
    dnd: on
    filtering: on
    elements: {
      gridId: '#myGrid'
      headerId: '#nested-dimension-header'
      footerId: '#nested-dimension-footer'
    }
    slickOptions: {
      maxTableHeight: 800
      autoHeight: true
      rowHeight: 30
      editable: true
      multiSelect: false
      enableAddRow: false
      enableCellNavigation: true
      enableColumnReorder: false
      forceFitColumns: true
    }
  }

  flagsStatus:
    addBtn: false

  initialize: () ->
    @options = $.extend true, {}, @defaults
    @slick = {}
    @hash = (new Date).getTime()
    window.__SlickInstances or= {}
    window.__SlickInstances[@hash] = @
    @data = []
    @search = val: ''
    $(window).resize (e) =>
      @renderMain()
    # TODO: migrate to more universal binding strategy
    mediator.on('searchString:change', (ss) =>
      if @groupItemMetadataProvider?
        @filterTable(ss)
    )

  render: () ->
    @$el.html @template(flags: @flagsStatus)
    @renderHeaderFooter()
    @

  renderHeaderFooter: () ->
    @$(@elements.headerId).html @header(flags: @flagsStatus)
    @$(@elements.footerId).html @footer(flags: @flagsStatus)
    @appendSearchBox()
    @

  appendSearchBox: () ->
    searchBoxTop = new SearchBoxView()
    @$('.search-box-container-top').append(searchBoxTop.render({
      id : 'top-filter',
      placeholder : 'filter table'
    }).el)
    searchBoxBottom = new SearchBoxView()
    @$('.search-box-container-bottom').append(searchBoxBottom.render({
      id : 'bottom-filter',
      placeholder : 'filter table'
    }).el)

  renderMain: ->
    @prepareData?()
    @prepareSlickGridRows()
    @prepareSlickGridColumns()
    @prepareSlickGridDataView()
    @renderSlickGrid()

  prepareSlickGridRows: ->
    @slick.slickData or= []

  prepareSlickGridColumns: ->
    @slickColumns or= []

  prepareSlickGridDataView: ->
    if @filtering
      myFilter = @myFilter.toString()
        .replace(/searchString/ig, "window.__SlickInstances[#{@hash}].search.val")
        .replace(/__view/ig, "window.__SlickInstances[#{@hash}]")
    @groupItemMetadataProvider = new Slick.Data.GroupItemMetadataProvider();
    @slick.dataView = new Slick.Data.DataView({
      inlineFilters: true
      groupItemMetadataProvider: @groupItemMetadataProvider
      modifier:
        viewInstance : @
        replacements  : @replaced_extractGroups
    })
    {dataView, slickData} = @slick
    dataView.beginUpdate()
    dataView.setItems(slickData)
    dataView.setFilter(myFilter) if @filtering
    dataView.endUpdate()
    dataView.getItemMetadata = @row_metadata.call(@, dataView.getItemMetadata)


  renderSlickGrid: ->
    $.extend true, @slickOptions,
      modifier:
        viewInstance: @
        replacements: @replaced_appendCellHtml
    # the MAIN string, creating the table
    @slick.gridSlick = new Slick.Grid(@elements.gridId, @slick.dataView, @slickColumns, @slickOptions)
    # add grouping plugin to table
    @slick.gridSlick.registerPlugin(@groupItemMetadataProvider)
    # set selection model for the table
    @slick.gridSlick.setSelectionModel(new Slick.RowSelectionModel());
    @subscribeTableEvents()
    @updateSlider($(@elements.gridId))
    # call func to enable drag'n'drop
    @initializeDnD() if @dnd


  onDragInit: (e, dd) ->
    # prevent the grid from cancelling drag'n'drop by default
    e.stopImmediatePropagation()

  onRowsChanged: (e, args) ->
    {gridSlick} = @slick
    gridSlick.invalidateRows args.rows
    gridSlick.render()
    gridSlick.resizeCanvas()
    @updateSlider()

  onRowCountChanged: (e, args) ->
    {gridSlick} = @slick
    gridSlick.updateRowCount()
    gridSlick.render()

  subscribeTableEvents: () ->
    {gridSlick, dataView} = @slick
    dataView.onRowsChanged.subscribe     => @onRowsChanged.apply     @, arguments
    dataView.onRowCountChanged.subscribe => @onRowCountChanged.apply @, arguments
    if @dnd
      gridSlick.onDragInit.subscribe     => @onDragInit.apply        @, arguments


  ######################################################################
  # Drag and drop functionality
  ######################################################################



  # enable drag and drop on table rows
  initializeDnD: ->
    moveRowsPlugin = new Slick.RowMoveManager();
    # no point in moving before or after itself
    moveRowsPlugin.onBeforeMoveRows.subscribe => @_onBeforeMoveRows.apply @, arguments
    # when moving row
    moveRowsPlugin.onMoveRows.subscribe => @_onMoveRows.apply @, arguments
    @slick.gridSlick.registerPlugin(moveRowsPlugin)



  _onBeforeMoveRows: (e, {insertBefore, rows}) ->
    {gridSlick, dataView} = @slick
    gridData = gridSlick.getData()
    groups = gridData.getGroups()
    len = gridSlick.getDataLength()
    # do not allow drop if we trying to drag a header row
    if not gridSlick.getDataItem(rows[0]).name?
      e.stopImmediatePropagation()
      return false
    # do not allow drop if we trying to do it if the row is inside its group
    curRowId = ''
    insRowId = ''
    curDim = @slick.slickData[0].current_dimension
    if insertBefore is 0 or insertBefore is len
      e.stopPropagation()
      return false
    else
      curRowId = gridSlick.getDataItem(rows[0])[curDim + '_id']
      insRowId =  gridSlick.getDataItem(insertBefore)[curDim + '_id']
      insInsRowId = gridSlick.getDataItem(insertBefore - 1)[curDim + '_id']
      if not insRowId? and insInsRowId is curRowId
        e.stopPropagation()
        return false
    if curRowId is insRowId
      e.stopPropagation()
      return false
    true



  _onMoveRows: (e, {insertBefore, rows}) ->
    {gridSlick, dataView} = @slick
    gridData = gridSlick.getData()
    groups = gridData.getGroups()
    rows.sort (a, b) ->
      a - b
    _gInd = 0
    # find what rows in the table are headers of groups
    groupMap = _.map [0..gridSlick.getDataLength() - 1], (i)-> if (dataView.getItemMetadata(i).cssClasses.indexOf('parent') isnt -1) then _gInd++ else null
    # divide this mass by the point where to drop row and get the first part
    groupsToIter = groupMap.slice(0, insertBefore)
    groupsToIter = groupsToIter.reverse()
    # get the index of group where to drop item
    gIndToDrop = _.find groupsToIter, (v)-> v isnt null
    # get the name of group where to drop item
    group = groups[gIndToDrop]
    x = _.filter [0..rows[0]], (v, k) -> groupMap[k] isnt null
    i = rows[0] - x.length
    args = arguments
    Array::push.call(args, {_gridSlick: gridSlick, group: group})
    @_onMoveRowsChild && @_onMoveRowsChild.apply(@, args)




  groupTableItems: (groupByStr) ->
    @slick.dataView.beginUpdate()
    @slick.dataView.groupBy(
      groupByStr,
    ((g) ->
      g.value + "  <span>(" + g.count + " items)</span>"
    ),
    ((A, B) ->
      a = A.value.toLowerCase()
      b = B.value.toLowerCase()
      if a > b then 1
      else if a < b then -1
      else 0
    ))
    @slick.dataView.endUpdate()


  # controls button and text box allowing the user to add a record for the
  # current dimension.
  addClicked: (e) ->
    switch e.target.type
    # If button is pressed:
      when 'submit'
      # If add-button clicked first time, show input-text:
        if !@flagsStatus.addBtn
          obj_input = $(e.target.parentElement).find 'input[type=text]'
          $(obj_input).show 1000
          @flagsStatus.addBtn = true
          # If add-button clicked second time, get text from input-text:
        else
          obj_input = $(e.target.parentElement).find 'input[type=text]'
          text = $(obj_input).val()
          @addDimension(text, obj_input) if text isnt ''
    # If text-input is pressed
      when 'text'
        if e.keyCode is 13
          text = e.target.value
          @addDimension(text, e.target) if text isnt ''


  # views extending this view will call their own version of this method,
  # beginning with `super` and followed by unique requirements
  addDimension: (text, widget) ->
    $(widget).empty().hide()
    @flagsStatus.addBtn = false
    @slick.gridSlick.render()


  myFilter: (item, args) ->
    return true if searchString is ""
    ss = new RegExp searchString, 'i'
    return true if ss.test item['name']
    false

  # performs filter on object table while resetting table features
  filterTable: (ss) ->
    @search.val = ss
    @flagsStatus.addBtn = false
    @$('.filter-list').val(ss)
    if ss.length
      @$('.icon-eliminate').show()
    else
      @$('.icon-eliminate').hide()
    @slick.dataView.refresh()
    @slick.gridSlick.render()

  # include placeholder methods for minichart and metric values, but these
  #   should be overridden by subclasses
  miniChartOptions: -> ''
  metricValue: -> '-'



  replaced_extractGroups: ->
    __scope.extractGroups = (rows) ->
      groups = []
      groupsByVal = []
      dimension = []
      curDim = ""
      curDim = rows[0]["current_dimension"]  if rows.length
      _.each rows, (r) =>
        val = (if (groupingGetterIsAFn) then groupingGetter(r) else r[groupingGetter])
        val = val or 0
        switch curDim
          when "segment"
            dimension = app.segments.find((item) ->
              item.get("name") is val
            )
          when "channel"
            dimension = app.channels.find((item) ->
              item.get("name") is val
            )
          when "revenue_stream"
            dimension = app.revenueStreams.find((item) ->
              item.get("name") is val
            )
          when "employee_type"
            dimension = app.employeeTypes.find((item) ->
              item.get("name") is val
            )
          when "Asset"
            dimension = view.slick.groupIds.Asset[val]
          when "Liability"
            dimension = view.slick.groupIds.Liability[val]
          when "Equity"
            dimension = view.slick.groupIds.Equity[val]
          when "Expense"
            dimension = view.slick.groupIds.Expense[val]
          when "Revenue"
            dimension = view.slick.groupIds.Revenue[val]
          when "category"
            dimension = app.categories.find((item) ->
              item.get("name") is val
            )
        group = groupsByVal[val]
        unless group
          group = new Slick.Group()
          group.count = 0
          group.id = dimension.id  if dimension
          group.value = val
          group.rows = []
          groups[groups.length] = group
          groupsByVal[val] = group
        group.rows[group.count++] = r
      groups





  replaced_appendCellHtml: ->
    __scope.appendCellHtml = (stringArray, row, cell, colspan) ->
      m = columns[cell]
      d = getDataItem(row)
      cellCss = "slick-cell l" + cell + " r" + Math.min(columns.length - 1, cell + colspan - 1) + ((if m.cssClass then " " + m.cssClass else ""))
      cellCss += (" active")  if row is activeRow and cell is activeCell

      # TODO:  merge them together in the setter
      for key of cellCssClasses
        cellCss += (" " + cellCssClasses[key][row][m.id])  if cellCssClasses[key][row] and cellCssClasses[key][row][m.id]
      stringArray.push "<div class='" + cellCss + "'>"

      # if there is a corresponding row (if not, this is the Add New row or this data hasn't been loaded yet)
      if d
        value = getDataItemValueForColumn(d, m)

        # if it is a first column
        if m["field"] is "name"

          # if it is a row with parent element
          if d["__group"]
            dimension = null
            dimensionStr = d.rows[0].current_dimension
            dimension = app.channels.get(d["id"])  if dimensionStr is "channel"
            dimension = app.segments.get(d["id"])  if dimensionStr is "segment"
            dimension = app.revenueStreams.get(d["id"])  if dimensionStr is "revenue_stream"
            dimension = app.employeeTypes.get(d["id"])  if dimensionStr is "employee_type"
            if dimensionStr is "category"
#            if ["category", "categorie"].indexOf(dimensionStr) isnt -1
              dimensionStr = "categorie"
              dimension = app.categories.get(d["id"])
            stringArray.push "<a href='#" + dimensionStr + "s/" + dimension.id + "/show'>"  if ["Asset", "Liability", "Expense"].indexOf(dimensionStr) is -1  if dimensionStr
          else

            # if it is a row with child element
            stringArray.push "<a href='#" + m["name"] + "s/" + d["id"] + "/show'>"  if ["account", "stage"].indexOf(m["name"]) is -1

        # source code
        stringArray.push getFormatter(row, m)(row, cell, value, m, d)

        # my code
        stringArray.push "</a>"  if m["field"] is "name" and m["name"]
      stringArray.push "</div>"
      rowsCache[row].cellRenderQueue.push cell
      rowsCache[row].cellColSpans[cell] = colspan

