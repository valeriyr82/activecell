FinancialStatementView = require('views/shared/slick_grid/financial_statement_view')

module.exports = class ChannelsShowProfitLossView extends FinancialStatementView
  # names of groups which should be presented in the table. except names which should not be presented
  namesToSort: ['Revenue', 'Cost of Goods Sold', 'Expense']

  initialize: ->
    super
    @slick.namesToSort = @namesToSort
    @initFilterMethod()

  initFilterMethod: ->
    window.__FinancialItemFilter = (instance, item) =>
      items = instance.slick.dataView.getItems()
      getParentElement = (el) ->
        s = el.parent_str
        return null unless s?
        _.find items, (i)-> i.account is s
      f = (el)->
        parent = getParentElement el
        return true unless parent?
        return false if parent._collapsed
        return f parent
      return f item

  prepareData: ->
    # 1) to realize a multiple dimension in the table you should set an indent to the row and its parent row account (parent_str).
    #    if it has no parent element it must have parent_str == null
    # 2) to create a total row we need to insert it after a last row of a group. it must have the following attributes:
    #    parent: the same as group rows; account: 'total'; amount: 0; indent: 0; parent_str: null

    @data = [
      {id: '0',   parent: 'Revenue',            account: 'revenue',          amount: '',      indent: 0,  parent_str: null}
      {id: '1',   parent: 'Revenue',            account: 'rev1',             amount: 500000,  indent: 1,  parent_str: 'revenue'}
      {id: '2',   parent: 'Revenue',            account: 'rev2',             amount: 50000,   indent: 1,  parent_str: 'revenue'}
      {id: '3',   parent: 'Revenue',            account: 'rev3',             amount: 5000,    indent: 1,  parent_str: 'revenue'}
      {id: '333', parent: 'Revenue',            account: 'total',            amount: 0,       indent: 1,  parent_str: 'revenue'}
      {id: '4',   parent: 'Cost of Goods Sold', account: 'cogs',             amount: '',      indent: 0,  parent_str: null}
      {id: '5',   parent: 'Cost of Goods Sold', account: 'cogs1',            amount: 100000,  indent: 1,  parent_str: 'cogs'}
      {id: '6',   parent: 'Cost of Goods Sold', account: 'cogs2',            amount: 10000,   indent: 1,  parent_str: 'cogs'}
      {id: '7',   parent: 'Cost of Goods Sold', account: 'cogs3',            amount: 1000,    indent: 1,  parent_str: 'cogs'}
      {id: '777', parent: 'Cost of Goods Sold', account: 'total',            amount: 0,       indent: 1,  parent_str: 'cogs'}
      {id: '8',   parent: 'Gross Margin',       account: 'Gross Margin',     amount: 444000,  indent: 0,  parent_str: null}
      {id: '9',   parent: 'Expense',            account: 'expense',          amount: '',      indent: 0,  parent_str: null}
      {id: '10',  parent: 'Expense',            account: 'exp1',             amount: 1000,    indent: 1,  parent_str: 'expense'}
      {id: '11',  parent: 'Expense',            account: 'exp2',             amount: 2000,    indent: 2,  parent_str: 'exp1'}
      {id: '12',  parent: 'Expense',            account: 'exp3',             amount: 3000,    indent: 3,  parent_str: 'exp2'}
      {id: '13',  parent: 'Expense',            account: 'exp4',             amount: 4000,    indent: 4,  parent_str: 'exp3'}
      {id: '14',  parent: 'Expense',            account: 'exp5',             amount: 5000,    indent: 1,  parent_str: 'expense'}
      {id: '15',  parent: 'Expense',            account: 'exp6',             amount: 200000,  indent: 2,  parent_str: 'exp5'}
      {id: '16',  parent: 'Expense',            account: 'exp7',             amount: 125000,  indent: 2,  parent_str: 'exp5'}
      {id: '17',  parent: 'Expense',            account: 'exp8',             amount: 12345,   indent: 2,  parent_str: 'exp5'}
      {id: '1777',parent: 'Expense',            account: 'total',            amount: 0,       indent: 1,  parent_str: 'expense'}
      {id: '18',  parent: 'Net Contribution',   account: 'Net Contribution', amount: 91655,   indent: 0,  parent_str: null}
    ]

  rowNameFormatter: (row, cell, value, columnDef, dataContext) ->
    data = @slick.dataView.getItems()
    spacer = "<span style='display:inline-block;height:1px;width:" + (15 * dataContext["indent"]) + "px'></span>"
    idx = @slick.dataView.getIdxById(dataContext.id)
    if data[idx + 1] and data[idx + 1].indent > data[idx].indent
      if dataContext._collapsed
        spacer + " <span class='slick-group-toggle collapsed'></span>&nbsp;" + value
      else
        spacer + " <span class='slick-group-toggle expanded'></span>&nbsp;" + value
    else
      if dataContext.account is 'total'
        return spacer + " <span class='slick-group-toggle'></span>&nbsp;" + value + ' ' + dataContext.parent.toLowerCase()
      spacer + " <span class='slick-group-toggle'></span>&nbsp;" + value

  groupNamesFormatter: (row, cell, value, columnDef, dataContext) ->
    if !dataContext.parent_str? and _.indexOf(@slick.namesToSort, dataContext.parent) isnt -1
      if dataContext._collapsed
        switch columnDef.field
          when 'amount'
            return app.formatters.usdCommas(@slick.slickDataTotal[dataContext.parent])
          when 'percent-revenue'
            return app.formatters.percentTwoPlacesCommas(@slick.slickDataTotal[dataContext.parent] / 555000)
      else
        return ''
    value


  myFilter: (item, args) ->
    return __FinancialItemFilter __view, item

  subscribeTableEvents: () ->
    super
    @slick.gridSlick.onClick.subscribe (e, args) =>
      if $(e.target).hasClass("slick-group-toggle")
        item = @slick.dataView.getItem(args.row)
        if item
          item._collapsed = not item._collapsed
          @slick.dataView.updateItem item.id, item
        e.stopImmediatePropagation()


  prepareSlickGridRows: ->
    @slick.slickData or= {}
    @slick.slickDataTotal or= {}
    for item in @namesToSort
      @slick.slickDataTotal[item] = 0
    @slick.slickData = for data in @data
      if data.account is 'total' and _.indexOf(@namesToSort, data.parent) isnt -1
        for d in @data
          if d.parent is data.parent and d.account isnt 'total' and d.parent_str?
            data['amount'] += d.amount
            @slick.slickDataTotal[data['parent']] += d.amount
    @slick.slickData = for data in @data
      data['percent-revenue'] = app.formatters.percentTwoPlacesCommas(data['amount'] / 555000)
      data['amount'] = app.formatters.usdCommas(data['amount'])
      data

  prepareSlickGridColumns: ->
    @slickColumns = [
      {
        id: 'account'
        name: 'account'
        field: 'account'
        formatter: ()=> @rowNameFormatter.apply @, arguments
      },
      {
        id: 'amount'
        name: 'amount'
        field: 'amount'
        cssClass: 'align-right'
        headerCssClass: 'align-right'
        formatter:  ()=> @groupNamesFormatter.apply @, arguments
      },
      {
        id: 'percent-revenue'
        name: '% of revenue'
        field: 'percent-revenue'
        cssClass: 'align-right'
        headerCssClass: 'align-right'
        formatter:  ()=> @groupNamesFormatter.apply @, arguments
      }
    ]

  prepareSlickGridDataView: () ->
    super

  # TODO pull dynamically!!!
  metricValue: ->
    app.formatters.usdCollapsible(8392038)