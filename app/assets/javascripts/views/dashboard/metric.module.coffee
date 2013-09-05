BaseView            = require('views/shared/base_view')
ReportAnalysis      = require('models/report_analysis')
MetricSelectionView = require('views/shared/modal/metric_selection')
D3DashboardView     = require('views/shared/d3_chart/dashboard_view')

module.exports = class DashboardMetricView extends BaseView
  metricStubTemplate:   JST['dashboard/metric/stub']
  metricHeaderTemplate: JST['dashboard/metric/header']
  chooseMetricTemplate: JST['dashboard/metric/choose']
  d3DashboardTemplate:  JST['d3_chart/dashboard']

  events:
    'click .choose-metric' : 'showModalView'
    'click .edit-metric'   : 'showModalView'
    'click .delete-metric' : 'deleteMetric'

  render: (renderingOptions = {}) ->
    analysisId = @model?.get('analysisId')

    # check to determine if a metric has been selected by the user
    if _.isEmpty(analysisId)
      # if not, render metric selection template
      @$el.html @chooseMetricTemplate()
    else
      # if so, retrieve analysis options/data and render metric
      name = app.settings.getName(analysisId)
      analysisCategory  = @model.get('analysisCategory')
      prefix            = @model.get('prefix')
      showId            = @model.get('showId')
      analysisKlass = require("views/#{analysisCategory}/#{prefix}_#{analysisId}")
      
      analysisView = @createView analysisKlass, id: showId
      options = analysisView.dashboardOptions()
      if options?
        options['name'] = name
        options['analysisCategory'] = analysisCategory
        options['analysisId'] = analysisId
        d3ChartView = @createView D3DashboardView, options
        @$el.html d3ChartView.render().el
        d3ChartView.renderChart() if renderingOptions.instantRender
      else
        @$el.html(@metricHeaderTemplate(name: name, link: "##{analysisCategory}/#{analysisId}") + @metricStubTemplate())
    @

  showModalView: ->
    skips = for item in @collection.toJSON()
      category: item.category, id :item.analysisId
    modalView = @createView MetricSelectionView, collection: @collection, model: @model, callback: @render, skips: skips
    @$el.append modalView.render(search: true, allowJumpTo: false).el
    modalView.show()

  deleteMetric: ->
    @model.save(analysisId: '')
    @render()