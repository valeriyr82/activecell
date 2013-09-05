NestedDimensionView = require('views/shared/slick_grid/nested_dimension_view')

module.exports = class CompanyCOAView extends NestedDimensionView
  flagsStatus: 
    parentDimension: 'company'
    selectDimension: 'Asset'
    allowAdd: false
    allowToggle: false
    allowSelect: true
    groupElements: true
    selectMass: ['Asset', 'Liability', 'Equity', 'Revenue', 'Cost of Goods Sold', 'Expense', 'Non-Posting']

  # should be an object to copy by reference
  events: 
    'change .select-account-type' : 'accountTypeChanged'

  initialize: ->
    super
    _.extend @events, NestedDimensionView::events
    _.extend @flagsStatus, NestedDimensionView::flagsStatus

  prepareSlickGridRows: ->
    @slick.slickData = []
    for account in app.accounts.models
      if account.get('type') is @flagsStatus.selectDimension
        @slick.slickData.push
          id: account.get('id')
          name: account.get('name')
          type: account.get('type')
          activecell_category: account.get('activecell_category')
          current_balance: app.formatters.usdCollapsible account.get('current_balance')
          revenue: app.formatters.usdCollapsible account.trailing12mRevenue()
          spend: app.formatters.usdCollapsible account.trailing12mSpend()
          main_dimension: 'account'
          current_dimension: @flagsStatus.selectDimension
    # we have no collections for activecell_category, so we will keep their temporary id in global object
    # this object has the following structure:
    
#                        cash
#                Asset <
#              /         non-cash
#             /  
#            /                  short-term
#    groupIds -  Liabilities <
#            \                  long-term
#             \ 
#              \           payroll
#                Expense < sales & marketing
#                          other

    @slick.groupIds = {}
    selectMass = @slick.groupIds[@flagsStatus.selectDimension] = {}
    for item in @slick.slickData
      actCellCatMass = selectMass[item.activecell_category] = {}
      actCellCatMass.id = switch item.activecell_category
        when 'cash'       then 1010
        when 'non-cash'   then 1011
        when 'short-term' then 1020
        when 'long-term'  then 1021
        when 'payroll'    then 1030
        when 'sales & marketing' then 1031
        when 'other'      then 1032
      item[@flagsStatus.selectDimension + '_id'] = actCellCatMass.id

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
        id: 'current_balance'
        name: 'current balance'
        field: 'current_balance'
        cssClass: 'align-right'
        headerCssClass: 'align-right'
      }
    ]

  prepareSlickGridDataView: () ->
    super
    if @flagsStatus.groupElements
      @groupTableItems 'activecell_category'

  accountTypeChanged: (e) =>
    # change select dimension
    @flagsStatus.selectDimension = e.target.value
    # group elements by default
    @flagsStatus.groupElements = true
    # reorganize massive with data
    @prepareSlickGridRows()
    # set new data to dataView
    @slick.dataView.setItems(@slick.slickData)
    # reset columns to their default, if any change is necessary, it will be done below
    @prepareSlickGridColumns()
    # group items by default, if we do not need grouping, it will be changed below'
    @groupTableItems 'activecell_category'

    # if Non-Posting table, show only one column
    switch @flagsStatus.selectDimension
      when 'Equity'
        @flagsStatus.groupElements = false
        @groupTableItems null
        @slickColumns[0].behavior = ''
        @slickColumns[0].cssClass = ''
      when 'Revenue'
        @slickColumns[1].name = 'revenue (trailing 12m)'
        @slickColumns[1].field = 'revenue'
        @groupTableItems null
      when 'Cost of Goods Sold'
        @slickColumns[1].name = 'spend (trailing 12m)'
        @slickColumns[1].field = 'spend'
        @flagsStatus.groupElements = false
        @groupTableItems null
        @slickColumns[0].behavior = ''
        @slickColumns[0].cssClass = ''
      when 'Expense'
        @slickColumns[1].name = 'spend (trailing 12m)'
        @slickColumns[1].field = 'spend'
      when 'Non-Posting'
        @slickColumns.splice(1,1)
        @flagsStatus.groupElements = false
        @groupTableItems null
        @slickColumns[0].behavior = ''
        @slickColumns[0].cssClass = ''

    @slick.gridSlick.setColumns(@slickColumns);
    @slick.dataView.refresh()
    @slick.gridSlick.render()
    @renderHeaderFooter()

  _onMoveRowsChild: (e, {insertBefore, rows}, {_gridSlick, group}) ->
    model = []
    curDim = @slick.slickData[0].current_dimension

    if curDim
      _gridSlick.getDataItem(rows[0])['activecell_category'] = group.value
      _gridSlick.getDataItem(rows[0])[curDim + '_id'] = group.id if group.id
      model = app.accounts.find((item) ->
        item.id is _gridSlick.getDataItem(rows[0])['id']
      )
      model.set { activecell_category : group.value } if model

    @slick.dataView.refresh()
    @slick.gridSlick.render()
