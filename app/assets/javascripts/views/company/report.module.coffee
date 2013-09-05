AnalysisView        = require('views/shared/analysis_view')
ReportAnalysis      = require('models/report_analysis')
MetricSelectionView = require('views/shared/modal/metric_selection')

module.exports = class CompanyReport extends AnalysisView
  newMetric:  JST['company/new_metric']
  events:
    'click .choose-metric' : 'showModalView'

  initialize: (options) ->
    @report     = app.reports.get(options.reportId)
    @collection = @report.analyses

    @model = if @collection.length is 0 or options.analysisId is 'new'
      metric = new ReportAnalysis()
      @collection.add(metric)
      metric
    else if options.analysisId
      @collection.get(options.analysisId)
    else if @collection.length > 0
      @collection.first()

  render: ->
    super
    if @model.isNew() then @renderNew() else @renderModel()
    @

  renderNew: ->
    @$('#main_chart').html @newMetric()

  showModalView: ->
    skipIds   = @collection.pluck('type')
    modalView = @createView MetricSelectionView, collection: @collection, model: @model, skip: skipIds, callback: =>
      app.navigate("company/reports/#{@report.id}/#{@model.id}", true)
    @$el.append modalView.render().el
    modalView.show()

  renderModel: ->
    # pull analysis attributes
    analysisId  = @model.get('analysisId')
    category    = @model.get('analysisCategory')
    prefix      = @model.get('prefix')
    showId      = @model.get('showId')

    # get nav item analysis
    mainKlass = require("views/#{category}/#{prefix}_#{analysisId}")
    mainView = @createView mainKlass, id: showId
    
    el = mainView.render().el
    # need to place the rendered template there so renderMain internals will work correctly
    # even though router module will replace the contents of #page_content again with the @el 
    $('#page_content').html el 
    @el = el
    mainView.renderMain() if mainView.renderMain?
    
    
    