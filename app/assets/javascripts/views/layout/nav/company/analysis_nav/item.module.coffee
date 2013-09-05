ItemView = require('views/layout/nav/analysis_nav/item')

module.exports = class CompanyAnalysisNavItemView extends ItemView
  template: JST['layout/nav/company/analysis_nav/item']
  events:
    'click .delete-metric' : 'destroy'

  render: ->
    @$el.html @template(name: @name, path: @path, showActions: @model)
    @$el.attr 'id', @analysisId
    @

  destroy: (event) ->
    @model.destroy()
    @remove()
    app.navigate(@backPath, true)
