Tasks = require('collections/tasks')

module.exports = class Task extends Backbone.Model
  @charLimit: 140
  paramRoot: 'task'
  urlRoot: 'api/v1/tasks'
  
  validate:
    text:
      required: true
      maxlength: @charLimit

  toggle: ->
    @save(done: !@isDone())
      
  isDone: ->
    @get('done') || false

  inProgress: ->
    not @isDone()

  close: ->
    @set('done', true)
    @save()

  isRecurring: ->
    _.isString(@get('recurring'))

  isMy: ->
    app.user.id == @get('user_id')

  getCreatedAtTimestamp: ->
    new Date(@get('created_at')).getTime()

  # clear a 'virtual' argument we use
  parse: (json) ->
    delete json.hidden if json?
    json
