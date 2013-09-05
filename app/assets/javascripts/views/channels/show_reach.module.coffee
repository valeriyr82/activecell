Reach           = require('analysis/reach')
AnalysisView    = require('views/shared/analysis_view')
UpperChartView  = require('views/shared/d3_chart/upper_view')
WideTableView   = require('views/shared/slick_grid/wide_view')

module.exports = class ChannelsShowReachView extends AnalysisView
        
  # instantiate the analytics module and set the initial analysis timeframe
  initialize: ->
    super
    @reach = new Reach()
    @timeframe = [-5, 6]
    
    mediator.on 'timeframe:change', (start, end) =>
      refresh = () =>
        # TODO: see todo #45342 in analysis_nav
        if @mainChartView? # TODO resolve this strange hack. event is triggered twice, and the second time the view doesn't exists (?!)
          @timeframe = [ start, end ]
          @mainChartView.data = @data
          @mainChartView.axes['update']()
          @mainChartView.redrawChart()
          @prepareSlickGridColumns()
          @slick.gridSlick.setColumns(@slickColumns)
          @slick.gridSlick.render()
          @addCellClasses()
      _.throttle(refresh(),500)

    mediator.on 'data:update', () =>
      refresh = () =>
        # TODO: see todo #45342 in analysis_nav
        if @mainChartView? # TODO resolve this strange hack. event is triggered twice, and the second time the view doesn't exists (?!)
          @prepareData()
          @mainChartView.data = @data
          @mainChartView.axes['update']()
          @mainChartView.redrawChart()
      _.throttle(refresh(),500)

  # pass prepared data to tables/charts
  renderMain: ->
    @prepareData()
    @renderChart()
    @renderTimeSlider()
    @renderTable()
    
  redraw: ->
    @mainChartView.redraw()
  
  # refresh the data to reflect any changes
  prepareData: ->
    @data = []
    @reach = new Reach()
    rawData = @reach.get @availableTimeframe
    for periodId in @availableTimeframe
      for channelId, value of rawData[periodId]
        if channelId is @id
          @data.push
            periodId: periodId
            actual: if isNaN(value.actual) then '' else +value.actual
            plan: +value.plan
            variance: if isNaN(value.actual) then '' else +value.actual - value.plan

  renderChart: ->
    @mainChartView = @createView UpperChartView, @data
    @$('#main_chart').html @mainChartView.render().el

    # define scales and axes (note inverted domain for y-scale: bigger is up!),
    #   including the (required) update function that the chart can use
    x = d3.time.scale()
    y = d3.scale.linear()
    @mainChartView.axes['xAxis'] = d3.svg.axis().scale(x).tickSubdivide(true).tickFormat(d3.time.format("%b"))
    @mainChartView.axes['yAxis'] = d3.svg.axis().scale(y).ticks(4).orient("left")

    # axes['update'] is a function used to recalculate dynamic axes by
    #   computing the desired x-axis range and the maximum y value.
    @mainChartView.axes['update'] = () =>
      first = _.first(@timeframe)
      last = _.last(@timeframe)
      seriesSize = 1 + last - first
      x.domain([
        app.periods.indexToDate(first),
        app.periods.indexToDate(last)
      ])
      y.domain([0, d3.max(@data, (d) -> Math.max(d.actual, d.plan))]).nice()
      @mainChartView.axes['xAxis'].seriesSize = seriesSize
    @mainChartView.axes['update']() # set initial timeframe

    # define series
    @mainChartView.series.push {
      id: 'reach-actual'
      type: 'column'
      title: 'reach, actual'
      color: app.formatters.chartColors[app.formatters.colorHierarchy[0]+'30']
      xValue: (d) -> x(app.periods.idToDate(d.periodId))
      tooltip: (d) ->
        "#{d.actual} customers " +
         "on #{app.periods.idToMonthYearString(d.periodId)}"          
      yValue: (d) -> y(d.actual)
    }

    @mainChartView.series.push {
      id: 'reach-plan'
      type: 'line'
      title: 'reach, plan'
      color: app.formatters.chartColors[app.formatters.colorHierarchy[1]+'30']
      xValue: (d) -> x(app.periods.idToDate(d.periodId))
      tooltip: (d) -> 
        "#{d.plan} customers planned " +
         "for #{app.periods.idToMonthYearString(d.periodId)}"
      yValue: (d) -> y(d.plan)
    }

  renderTable: ->
    view = @createView WideTableView
    @$('#main_table1').html view.render().el
    @prepareSlickGridColumns()
    @prepareSlickGridRows()
    @prepareSlickGridOptions()
    @prepareSlickGridDataView()
    @renderSlickGrid()

  prepareSlickGridColumns: ->
    @slickColumns = []
    @slickColumns.push {
      id: 'row_header'
      name: ''
      field: 'row_header'
      cssClass: "cell-reorder dnd"
    }

    timeframe = app.periods.range(@timeframe[0],@timeframe[1])
    timeframeLength = timeframe.length
    # if there are less then 12 periods, show them
    # else show the first 12 from periods
    for periodId in (if timeframeLength <=12 then timeframe else timeframe[0..12])
      @slickColumns.push {
        id: periodId
        name: app.periods.idToCompactString(periodId)
        field: periodId
        cssClass: "align-right editable id_#{periodId}"
        headerCssClass: 'align-right'
        editor: Slick.Editors.Text
      }

  prepareSlickGridRows: ->
    rows = ['actual','plan','variance']
    @slick.slickData = []
    for row in rows
      @slick.slickData.push {
        id: row
        row_header: row
        channel_id: @id
        }
    for d in @data
      for row, index in rows
        @slick.slickData[index][d['periodId']] = d[row]

  prepareSlickGridDataView: () ->
    @slick.dataView = {}
    @slick.dataView = new Slick.Data.DataView
    @slick.dataView.beginUpdate()
    @slick.dataView.setItems(@slick.slickData)
    @slick.dataView.endUpdate()
      
  prepareSlickGridOptions: ->
    @slickOptions = {
      autoHeight: true
      maxTableHeight: 400
      rowHeight: 30
      editable: true
      multiSelect: false
      enableAddRow: false
      enableCellNavigation: true
      enableColumnReorder: false
      forceFitColumns: true
    }
  
  renderSlickGrid: ->
    @slick.gridSlick = {}
    @slick.gridSlick = new Slick.Grid(".slick-grid-table", @slick.dataView, @slickColumns, @slickOptions)
    @slick.gridSlick.setSelectionModel(new Slick.RowSelectionModel());
    @subscribeTableEvents()
    @addCellClasses()
    
  addCellClasses: ->
    i = 0
    while i < @slick.gridSlick.getDataLength()
      j = 0
      while j < @slick.gridSlick.getColumns().length
        regExp = /id_([^\s]+)/i
        idStr = (regExp.exec @slick.gridSlick.getCellNode(i,j).className)
        if idStr
          if app.periods.notFuture(idStr[1]) and @slick.gridSlick.getDataItem(i).id isnt 'variance'
            $(@slick.gridSlick.getCellNode(i,j)).addClass 'editable'
            $(@slick.gridSlick.getCellNode(i,j)).addClass 'can-be-edited'
          else
            if @slick.gridSlick.getDataItem(i).id is 'plan'
              $(@slick.gridSlick.getCellNode(i,j)).addClass 'editable'
              $(@slick.gridSlick.getCellNode(i,j)).addClass 'can-be-edited'
        j++
      i++
    @slick.dataView.refresh()
    @slick.gridSlick.render()

  subscribeTableEvents: ->
    @slick.dataView.onRowsChanged.subscribe (e, args) ->
      @slick.gridSlick.invalidateRows args.rows
      @slick.gridSlick.render()

    @slick.gridSlick.onBeforeEditCell.subscribe (e,args) ->
      if (!app.periods.notFuture(args.column.id) and args.item.id is 'actual') or args.item.id is 'variance'
        return false

    @slick.gridSlick.onCellChange.subscribe (e, args) ->
      periodId = @getColumns()[args.cell].id
      newValue = args.item[periodId]
      attributes = {
        stage_id: app.stages.topline()?.id
        channel_id: args.item['channel_id']
        period_id: periodId
      }
      switch args.item.id
        when 'actual'
          # TODO: this doesn't handle creating new model, only updates
          _.first(app.conversionSummary.where(attributes))
            .save(
              { customer_volume: newValue }
              { success: -> window.mediator.trigger('data:update') }
            )
        when 'plan'
          _.first(app.conversionForecast.where(attributes))
            .save(
              { conversion_forecast: newValue }
              { success: -> window.mediator.trigger('data:update') }
            )

  # TODO pull dynamically!!!
  metricValue: ->
    app.formatters.intCommas(292)
    
  renderDashboard: ->
    @prepareData()
    
  renderMini: ->
    @prepareData()
