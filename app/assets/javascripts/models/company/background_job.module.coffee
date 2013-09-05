Model = require('models/shared/base_model')

module.exports = class BackgroundJob extends Model
  paramRoot: 'background_job'

  urlRoot: '/api/v1/background_jobs'
  url: ->
    if @id? then "#{@urlRoot}/#{@id}"
    else "#{@urlRoot}/last"

  canScheduleNextJob: ->
    status = @get('status')
    !status or @isCompleted() or @isFailed()

  isQueued: ->
    @get('status') is 'queued'

  isWorking: ->
    @get('status') is 'working'

  isScheduled: ->
    @isQueued() or @isWorking()

  isCompleted: ->
    @get('status') is 'completed'

  isFailed: ->
    @get('status') is 'failed'

  isFinished: ->
    @isCompleted() or @isFailed()

  getStepsTotal: ->
    @get('job_status').total

  getStepsNum: ->
    @get('job_status').num

  hasProgress: ->
    @getStepsNum()? and @getStepsTotal()?

  getStepsPercentage: ->
    Math.ceil(@getStepsNum() / @getStepsTotal() * 100)
