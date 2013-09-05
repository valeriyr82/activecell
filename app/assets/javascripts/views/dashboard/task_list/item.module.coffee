BaseView = require('views/shared/base_view')
Todos = require('collections/tasks')
TaskListItemView = require('views/dashboard/task_list/item')

module.exports = class TaskListItemView extends BaseView
  template: JST['dashboard/task_list/item']
  tagName: 'li'
  className: 'task-item'
  
  events:
    'click .checkbox': 'toggleTaskStatus'
    'click .recurring-options a': 'saveRecurrence'
    'click .delete-task': 'deleteTask'

  initialize: (options) ->
    @addEvent @model, 'change:done', @toggleElementStatus
    @addEvent @model, 'change:hidden', @toggleElementVisibility
    @addEvent @model, 'change:recurring', @renderSelectedRecurrence

  render: ->
    @$el.html @template(task: @model.toJSON())
    @renderSelectedRecurrence()
    @
    
  deleteTask: ->
    bootbox.confirm 'Are you sure?', (confirmed) =>
      return unless confirmed

      @model.destroy()
      @remove()

  toggleTaskStatus: =>
    @model.toggle()
    @collection.sort()
    
  toggleElementVisibility: (model) ->
    if model.get('hidden') then @$el.hide() else @$el.show()
    
  toggleElementStatus: ->
    @$el.find('.content').toggleClass('in-progress')
    @$el.find('.checkbox').toggleClass('blank-checkbox')

  renderSelectedRecurrence: ->
    @$el.find('li').removeClass('selected')
    if @model.isRecurring()
      @$el.find('.content').addClass('recurring') 
      $newNav  = @$("li[data-nav=#{@activeNav}]")
      
      @$el.find("[data-recurring=#{@model.get('recurring')}]")
        .closest('li')
        .addClass('selected')

  saveRecurrence: (ev) ->
    ev.preventDefault()
    recurrence = $(ev.currentTarget).data('recurring')
    recurrence = null if recurrence == ''
    @model.set('recurring', recurrence)
    @model.save()
