AnalysisNavView = require('../analysis_nav')
ItemView        = require('views/layout/nav/analysis_nav/item')
MiniChartView   = require('views/shared/d3_chart/mini_view')

module.exports = class CompanyAnalysisNavView extends AnalysisNavView
  
  initialize: (options) ->
    @report     = app.reports.get(options.reportId)
    @collection = @report.analyses

  render: ->
    @$el.html @template(prevTop: @prevTop)
    @collection.each @addOne
    @addNew() if @analysisId is 'new' or !@analysisId
    @

  addOne: (analysis) =>

    # pull analysis attributes
    analysisId  = analysis.get('analysisId')
    category    = analysis.get('analysisCategory')
    prefix      = analysis.get('prefix')
    showId      = analysis.get('showId')
    path = "company/reports/#{@report.id}/#{analysis.id}"    
    # path = if prefix is 'index' then "#{category}/#{analysisId}" else "#{category}/#{showId}/#{analysisId}"

    return unless analysisId?
    
    # get nav item analysis
    analysisKlass = require("views/#{category}/#{prefix}_#{analysisId}")
    analysisView = @createView analysisKlass, id: showId
    
    # build nav item
    itemView = @createView ItemView,
      name: app.settings.getName(analysisId)
      analysisId: analysis.id
      path: path
      metricValue: analysisView.metricValue()
    itemView.backPath = "company/reports/#{@report.id}"
    @$el.append itemView.render().el

    # build nav item minichart
    miniChartView = @createView MiniChartView, analysisView.miniChartOptions()
    $(itemView.el).find('.mini-chart').html miniChartView.render().el

  addNew: ->
    name = 'new analysis'
    path = "company/reports/#{@report.id}/new"
    view = @createView ItemView, name: name, analysisId: 'new', path: path, metricValue: '+'
    @$el.append view.render().el