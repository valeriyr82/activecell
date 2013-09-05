BaseView = require('views/shared/base_view')

module.exports = class BreadcrumbsView extends BaseView
  breadcrumbs: JST['layout/nav/breadcrumbs']
  el: '#breadcrumbs'

  setOptions: (options) ->
    @options = options
    @

  render: ->
    data = if @options.reportId then @companyData(@options) else @defaultData(@options)
    @$el.html @breadcrumbs(data)
    @

  defaultData: (options) ->
    {type, analysisId, prefix} = options
    showId        = options.id
    analysisItems = app.settings.getItems(type, prefix)

    data = {}
    data.subnavName   = @_humanize type
    data.analysisName = @_humanize analysisItems[analysisId]
    data.objectName   = @_humanize app.settings.getObjectName(type, showId) if prefix is 'show'
    data

  companyData: (options) ->
    collection = app.reports.customReports()
    model      = collection.get(options.reportId)

    subnavName: model.get('name')

  _humanize: (name = '') ->
    name.replace('_', ' ')
