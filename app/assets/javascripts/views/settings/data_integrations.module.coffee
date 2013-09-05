BaseView = require('views/shared/base_view')
BackgroundJobsView = require('views/settings/data_integrations/background_jobs')

module.exports = class DataIntegrations extends BaseView
  template: JST['settings/data_integrations']

  initialize: ->
    @company = app.company

  render: =>
    @$el.html @template(@company.toJSON())
    @renderBackgroundJobs() if @company.isConnectedToIntuit()
    @

  renderBackgroundJobs: =>
    view = @createView BackgroundJobsView
    @$('#background-jobs').html view.render().el
