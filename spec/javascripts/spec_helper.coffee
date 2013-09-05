# Stub report grid
window.ReportGrid =
  pivotTable: ->
  lineChart: ->
  barChart: ->

window.stubCurrentDate = (date) ->
  spyOn(moment.fn, 'startOf').andReturn moment(date)
