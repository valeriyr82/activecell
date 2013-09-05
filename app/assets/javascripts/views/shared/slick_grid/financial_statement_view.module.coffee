SlickGridView = require('views/shared/slick_grid/slick_grid_view')


module.exports = class FinancialStatementView extends SlickGridView

  template: JST['base_page/financial_statement/financial_statement']
  header: JST['base_page/financial_statement/financial_statement_header']
  # footer: JST['base_page/financial_statement_footer']

  initialize: ->
    super
    $.extend true, @, @options, {
      dnd: off
      filtering: on
      elements: {
        headerId: '#financial-statement-header'
        footerId: '#financial-statement-footer'
      }
      slickOptions: {
        editable: false
      }
    }

  renderHeaderFooter: () ->
    @$(@options.elements.headerId).html @header
    # @$(@options.elements.footerId).html @footer
    #   flags: @flagsStatus
    @

  row_metadata: (old_metadata_provider) ->
    groupNames = @namesToSort
    (row) ->
      item = @getItem(row)
      ret = old_metadata_provider(row)
      if item
        ret = ret or {}
        if item.__group or item.parent_str is null and _.indexOf(groupNames, item.parent) isnt -1
          if item._collapsed
            ret.cssClasses = (ret.cssClasses or "") + " collapsed"
          ret.cssClasses = (ret.cssClasses or "") + " parent"
        else
          if item.parent_str is null and _.indexOf(groupNames, item.parent) is -1
            ret.cssClasses = (ret.cssClasses or "") + " independant"
          else if item.account is 'total'
            ret.cssClasses = (ret.cssClasses or "") + " subtotal-alt"
          else
            ret.cssClasses = (ret.cssClasses or "") + " child"
      ret

  prepareSlickGridDataView: ->
    groupNames = @namesToSort
    super

  onRowsChanged: (e, args)->
    @slick.gridSlick.invalidateRows args.rows
    @slick.gridSlick.render()

  onDragInit: ->

  groupTableItems: (groupByStr) ->
    groupNameMas = @namesToSort
    @slick.dataView.beginUpdate()
    @slick.dataView.groupBy(
      groupByStr,
      ((g) ->
        g.value + "  <span>(" + g.count + " items)</span>"
      ),
      ((A, B) ->
        groupNameMas.indexOf(A.value) - groupNameMas.indexOf(B.value)
      ))
    @slick.dataView.endUpdate()

  miniChartOptions: -> ''
