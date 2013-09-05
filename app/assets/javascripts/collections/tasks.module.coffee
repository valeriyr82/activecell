Task = require('models/task')

module.exports = class Tasks extends Backbone.Collection
  url: 'api/v1/tasks'
  model: Task
  
  done: ->
    @filter (task) ->
      task.get("done")

  inProgress: ->
    @filter (task) ->
      !task.get("done")
 
  my: ->
    @filter (task) ->
      task.isMy()
      
  theirs: ->
    @filter (task) ->
      !task.isMy()
  
  comparator: (task, otherTask) ->
    # Compare statuses
    return -1 if task.inProgress() and otherTask.isDone()
    return 1 if task.isDone() and otherTask.inProgress()

    # Compare timestamps
    timestamp = task.getCreatedAtTimestamp()
    otherTimestamp = otherTask.getCreatedAtTimestamp()

    return -1 if timestamp > otherTimestamp
    return 0 if timestamp == otherTimestamp
    return 1 if timestamp < otherTimestamp
