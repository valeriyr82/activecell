BaseView      = require('views/shared/base_view')

module.exports = class CompanyAnalysisNavFooter extends BaseView
  template: JST['layout/nav/company/analysis_nav/footer']
  events:
    'click .delete-report' : 'destroyReport'

  initialize: (reportId)->
    @reportId = reportId

  render: ->
    @$el.html @template(reportId: @reportId)
    @

  destroyReport: ->
    mediator.trigger 'active_report:destroy'