NestedDimensionView = require('views/shared/slick_grid/nested_dimension_view')

module.exports = class EmployeeTypesIndexListView extends NestedDimensionView
  flagsStatus: 
    allowAdd: false
    allowToggle: false

  initialize: ->
    super
    _.extend @events, NestedDimensionView::events
    _.extend @flagsStatus, NestedDimensionView::flagsStatus

  prepareSlickGridRows: ->
    @slick.slickData or= {}
    @slick.slickData = for employee in app.employees.toJSON()
      id: employee.id
      name: employee.name
      employee_type: employee.employee_type.name
      employee_type_id: employee.employee_type.id
      employee_type_collection: app.employeeTypes
      comp: app.formatters.usdCollapsible app.employees.
        get(employee.id).trailing12mComp()
      main_dimension: 'employee'
      current_dimension: 'employee_type'
      
  prepareSlickGridDataView: () ->
    super
    @groupTableItems 'employee_type'
    groups = @slick.dataView.getGroups()
    for group in groups
      @slick.dataView.collapseGroup(group.value)

  prepareSlickGridColumns: ->
    @slickColumns = [
      {
        id: 'name'
        name: 'employee'
        field: 'name'
        behavior: "selectAndMove"
        cssClass: "cell-reorder dnd"
      },
      {
        id: 'comp-12mt'
        name: 'comp (trailing 12m)'
        field: 'comp'
        cssClass: 'align-right'
        headerCssClass: 'align-right'
      }
    ]

  _onMoveRowsChild: (e, {insertBefore, rows}, {_gridSlick, group}) ->
      model = []
      curDim = @slick.slickData[0].current_dimension
      mainDim = @slick.slickData[0].main_dimension
      
      if curDim
        _gridSlick.getDataItem(rows[0])[curDim] = group.value
        _gridSlick.getDataItem(rows[0])[curDim + '_id'] = group.id if group.id
        model = app.employees.find((item) ->
          item.id is _gridSlick.getDataItem(rows[0])['id']
        )
        if model
          model.save { employee_type_id : group.id , employee_type : app.employeeTypes.get(group.id).toJSON()}

      @slick.dataView.refresh()
      @slick.gridSlick.render()
