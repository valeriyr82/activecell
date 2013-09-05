BaseView = require('views/shared/base_view')
BackgroundJob = require('models/company/background_job')

module.exports = class DataIntegrations extends BaseView
  template: JST['settings/data_integrations/background_jobs']

  events:
    'click button.queue': 'scheduleBackgroundJob'

  initialize: ->
    @company = app.company

    @backgroundJob = new BackgroundJob()
    @backgroundJob.on 'change', @render
    @backgroundJob.fetch
      success: (job) =>
        if @backgroundJob.isScheduled() then @scheduleProgressCheck()

  render: =>
    @$el.html @template(company: @company.toJSON(), job: @backgroundJob)
    @

  scheduleBackgroundJob: (event) ->
    event?.preventDefault()

    @company.scheduleBackgroundEtlJob
      success: (data) =>
        @backgroundJob = new BackgroundJob(data)
        if @backgroundJob.isScheduled()
          @scheduleProgressCheck()

  # periodically query for status
  fetchStatus: ->
    @backgroundJob.fetch
      success: =>
        if @backgroundJob.isFinished() then clearInterval(@intervalId)
        @render()

  scheduleProgressCheck: ->
    @intervalId = setInterval($.proxy(@fetchStatus, @), 1000)
