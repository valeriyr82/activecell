BaseView = require('views/shared/base_view')
Tasks = require('collections/tasks')
Task = require('models/task')
TaskListUsersPickView = require('views/dashboard/task_list/users_pick')

module.exports = class TaskListHeadView extends BaseView
  template: JST['dashboard/task_list/head']
  
  events:
    'focus .task-form textarea': 'enlargeTextarea'
    'blur .task-form textarea': 'shrinkTextarea'
    'keyup textarea': 'handleWritingKeys'
    'keydown textarea': 'handleNavigationKeys'
    'click .task-form textarea': 'deactivateUsersList'
    'click .task-switcher li': 'switchTasksByOwner'
    'click .clear-completed-tasks': 'clearCompleted'
    'click .show-completed-tasks': 'showCompleted'
    'click .hide-completed-tasks': 'hideCompleted'

  initialize: (options) ->
    @collection = options.collection
    @listView = options.list
  
  render: ->
    @$el.html(@template())
    # don't display the tasks filtering by user if this account has only one
    app.company.usersCount (count) =>
      if count > 1
        @$el.find(".task-switcher").removeClass('semi-transparent')
      else
        @$el.find(".task-switcher").hide()

    currentFilterEl = @$el.find(".task-switcher .tasks-#{@listView.currentFilter}")
    currentFilterEl.addClass('active')
    @textarea = @$el.find('textarea')
    
    # prepare users list
    @usersList = @createView TaskListUsersPickView, textarea: @textarea, headEl: @$el
    @$el.append @usersList.render().el
    
    # this helps us with triggering keystroke related events
    # we need to know whether a character was added on last keypress
    @_lastLengths = [0,0]
    
    @
    
  hideCompleted: (ev) ->
    ev.preventDefault()
    el = $(ev.currentTarget)
    @listView.hideCompleted() 
    @$('.show-completed-tasks').show()
    el.hide()
    
  showCompleted: (ev) ->
    ev.preventDefault()
    el = $(ev.currentTarget)
    @listView.showCompleted()
    @$('.hide-completed-tasks').show()
    el.hide()
    
  clearCompleted: (ev) ->
    ev.preventDefault()
    @listView.clearCompleted()

  switchTasksByOwner: (ev) ->
    clicked = $(ev.currentTarget)
    @$('.task-switcher li').removeClass('active')
    clicked.addClass('active')
    
    if clicked.hasClass('tasks-my')
      @listView.currentFilter = 'my'
    else
      @listView.currentFilter = 'all' 
      
    @listView.renderTasks()

  enlargeTextarea: ->
    @textarea.attr('rows', '3')
    @countChars()
    
  shrinkTextarea: ->
    if @textarea.val() == ''
      @textarea.attr('rows', '1') 
      @$el.find('.char-count').hide()
    
  handleNavigationKeys: (event) ->
    switch event.keyCode
      when 13 then @handleEnterKey(event)
      when 27 then @usersList.deactivate()
      when 38, 40 #up/down arrows
        @usersList.handleArrows(event)
      
  handleWritingKeys: (event) ->
    switch event.keyCode
      # navigation keys handled in other function
      when 13, 27, 38, 40
        return false
      else
        @_trackCharacters()
        @countChars()
        @usersList.lookupMentions()
    
    if @_charLengthChanged() and @lastChar == "@"
      @usersList.activate()
      return false
    
  countChars: ->
    chars = @textarea.val().length
    charCount = @$el.find('.char-count')
    charCount.show()
    charCount.text(Task.charLimit - chars)
    
    if (Task.charLimit - chars) < 0
      charCount.addClass('over-limit')
    else
      charCount.removeClass('over-limit')
      
  handleEnterKey: (event) ->
    event.preventDefault()
    event.stopPropagation()
    
    if @usersList.isActive()
      @usersList.chooseSelectedUser(event)
    else
      @submitTask()
    return false
    
  submitTask: ->
    text = @textarea.val()
    return false unless text
    userId = @$el.find('#mentioned-user-id').val()
    
    # remove mention from the task text
    
    if userId
      text = text.replace("@#{@usersList.selectedUser.get('name')}", '')
      text = $.trim(text)
      
    task = new Task(text: text, user_id: userId)
    
    # save task and add it to collection only on success 
    task.save {}, 
      success: (task, response) =>
        @collection.add task
        @textarea.val('')

  deactivateUsersList: ->
    @usersList.deactivate()
    
  _charLengthChanged: ->
    @_lastLengths[1] > @_lastLengths[0]
    
  _trackCharacters: ->
    text = @textarea.val()
    @lastChar = text.slice(-1)
    @_lastLengths[0] = @_lastLengths[1]
    @_lastLengths[1] = text.length
