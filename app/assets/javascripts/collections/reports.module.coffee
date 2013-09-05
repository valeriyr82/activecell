Report = require('models/report')

module.exports = class Reports extends Backbone.Collection
  url: 'reports'
  model: Report

  comparator: (report) ->
    (new Date(report.get 'created_at')).getTime()

  dashboard: ->
    report = @find (report) -> report.get('report_type') is 1
    if _.isEmpty(report)
      # Create dashboard with 4 empty analysis
      report = new Report(report_type: 1, analyses: [], name: 'Dashboard')
      @create report, success: (report) ->
        report.analyses.reportId = report.id
        _(4).times (i) -> report.analyses.create {type: ''}, success: ->
          report.trigger('first_init') if i is 4 - 1
    report

  customReports: ->
    reports = @select (report) -> report.get('report_type') is 0
    new Reports(reports)