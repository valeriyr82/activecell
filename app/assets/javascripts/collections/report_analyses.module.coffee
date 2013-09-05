ReportAnalysis = require('models/report_analysis')

module.exports = class ReportAnalyses extends Backbone.Collection
  model: ReportAnalysis

  initialize: (items, @reportId) ->
    super(items)

  url: ->
    "reports/#{@reportId}/analyses"

  comparator: (analysis) ->
    (new Date(analysis.get 'created_at')).getTime()

  clearNew: ->
    @each (item) -> item.destroy() if item.isNew()
