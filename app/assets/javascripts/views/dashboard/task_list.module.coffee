BaseView = require('views/shared/base_view')
Tasks = require('collections/tasks')
TaskListHeadView = require('views/dashboard/task_list/head')
TaskListItemView = require('views/dashboard/task_list/item')

module.exports = class TaskListView extends BaseView
  template: JST['dashboard/task_list']

  initialize: ->
    @collection = new Tasks()
    @collection.fetch()
    @currentFilter = 'all'

    @addEvent @collection, 'reset', @renderTasks
    @addEvent @collection, 'add', @renderTasks
    @addEvent @collection, 'remove', @renderTasks

  render: ->
    @$el.html @template()
    @renderHeader()
    @

  renderHeader: ->
    headerView = @createView TaskListHeadView, collection: @collection, list: @
    @$el.prepend headerView.render().el

  renderTasks: =>
    @$el.find(".task-list").html ''
    @collection.each @addOne
    @_applyUserFilter()

  addOne: (task) =>
    taskItemView = @createView TaskListItemView, model: task, collection: @collection
    @$el.find('.task-list').append taskItemView.render().el

  clearCompleted: ->
    _.each @collection.done(), (task) ->
      task.destroy()
      
  hideCompleted: ->
    _.each @collection.done(), (task) ->
      task.set('hidden', true)
      
  showCompleted: ->
    _.each @collection.done(), (task) ->
      task.set('hidden', false)
    @_applyUserFilter()

  _applyUserFilter: =>
    if @currentFilter == 'my'
      _.each @collection.theirs(), (task) ->
        task.set('hidden', true)
    else
      _.each @collection.models, (task) ->
        task.set('hidden', false)
