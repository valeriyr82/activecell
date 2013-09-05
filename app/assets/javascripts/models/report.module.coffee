ReportAnalyses = require('collections/report_analyses')

module.exports = class Report extends Backbone.Model
  initialize: ->
    @analyses = new ReportAnalyses(@get('analyses'), @id)

  validate: (attrs) ->
    return "Can't be blank" if _.isEmpty(attrs.name)
