BaseView = require('views/shared/base_view')
AddMetricToDashboardView = require('views/shared/modal/add_metric_to_dashboard')
ReportAnalysis = require('models/report_analysis')

module.exports = class AnalysisNavItemView extends BaseView
  template: JST['layout/nav/analysis_nav/item']
  tagName: 'li'

  events: 
    'click .icon-small-dashboard' : 'addToDashboard'
    'click .icon-small-plus2'     : 'addToCustomReport'

  initialize: (options = {}) ->
    {@name, @path, @analysisId, @metricValue} = options
    mediator.on 'metric-report:selected', (obj = {id : '', type : '', newName : ''}) =>
      if @existingAnalyses?
        switch obj.type
          when 'dashboard'
            @saveModel(obj.id, obj.className)
          when 'custom-report'
            @addToReport(obj.id)
          when 'create-report'
            @createReport(obj.newName)

  render: ->
    @$el.html @template(name: @name, path: @path, metricValue: @metricValue)
    @$el.attr 'id', @analysisId
    @$('.icon-analysis-nav').tooltip
      placement: 'right'
    @
    
  addToDashboard: ->
    collection = app.reports.dashboard().analyses 
    @existingAnalyses = collection.toJSON()
    if collection?
      unless collection.length < 4
        emptySlotsCollection = collection.filter((item)->
          item.get('analysisId') is ''
        )
        if !emptySlotsCollection.length
          # if all slots are occupied, request user to replace one of existing
          modal = new AddMetricToDashboardView(@existingAnalyses, 'dashboard')
        else
          # if there are free slots, fill the first of them
          @saveModel(emptySlotsCollection[0]?.id)
      else
        # this point is not used now, but it should be there just in case
        app.reports.dashboard().analyses.create().save(analysisCategory: app.currentView.options.type, prefix: app.currentView.options.prefix, analysisId: app.currentView.options.analysisId)
        
  addToCustomReport: ->
    collection = app.reports
    @existingAnalyses = collection.toJSON()
    if collection?
      modal = new AddMetricToDashboardView(@existingAnalyses, 'custom_report')

  saveModel: (id) ->
    model = app.reports.dashboard().analyses.get id
    model?.save(analysisCategory: app.currentView.options.type, prefix: app.currentView.options.prefix, analysisId: app.currentView.options.analysisId)
    # clear this variable for right work of mediator
    @existingAnalyses = null
    app.navigate("#dashboard", true)
    
  addToReport: (id) ->
    model = app.reports.get(id)
    @addCurrentReportToModel(model)

  createReport: (newName) ->
    app.reports.create {name: newName, created_at: new Date(), report_type: 0}, wait: true, success: (model) =>
      model.analyses.reportId = model.id
      @addCurrentReportToModel(model)

   addCurrentReportToModel: (model) ->
    collection = model.analyses
    report = new ReportAnalysis()
    report.set(analysisCategory: app.currentView.options.type, prefix: app.currentView.options.prefix, analysisId: app.currentView.options.analysisId)
    collection.create(report, {success: (metric) ->
      app.navigate("company/reports/#{model.id}/#{metric.id}", true)
    })
    # clear this variable for right work of mediator
    @existingAnalyses = null

