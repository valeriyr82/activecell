BaseView = require('views/shared/base_view')
Users = require('collections/users')

module.exports = class TaskListUsersPickView extends BaseView
  userTemplate: JST['dashboard/task_list/users_pick']
  tagName: "ul"
  id: 'users-list'
  className: "dropdown-list autocomplete-results"
  
  events:
    'click li': 'pickUser'
    
  initialize: (options) ->
    @textarea = options.textarea
    @headElement = options.headEl
    @fullCollection = new Users()
    @fullCollection.fetch
      success: => 
        @renderUsers()
  
  renderUsers: (searchPhrase = null) ->
    @fullCollection = new Users(@fullCollection.without app.user.id)
    # don't filter the original collection so we don't need to fetch it again
    @collection = @fullCollection
    
    @collection = new Users(@collection.searchByName(searchPhrase)) if searchPhrase
    
    @$el.html('')
    @collection.each (user) =>
      @$el.append @userTemplate(id: user.get('id'), name: user.get('name'))
    
    unless @collection.isEmpty()
      @selectedUser = @collection.first()
      @$el.find("li[data-user-id=#{@selectedUser.get('id')}]").addClass('selected')
      
    @
  
  handleArrows: (event) ->
    return unless @isActive()
    
    @$el.find('li').removeClass('selected')
    switch event.keyCode
      when 38 #go up
        @_selectPrevious()
      when 40 #go down
        @_selectNext()

    event.stopPropagation()
    event.preventDefault()
  
  # triggered on click
  pickUser: (event) ->
    @$el.find('li').removeClass('selected')
    target = $(event.currentTarget)
    target.addClass('selected')
    @selectedUser = @collection.get(target.data('user-id'))
    @chooseSelectedUser()
    
  chooseSelectedUser: ->
    @textarea.focus()
    @headElement.find("#mentioned-user-id").val(@selectedUser.get('id'))
    
    text = @textarea.val()
    searchPhrase = text.slice(text.indexOf("@"), _.getCaretPosition(@textarea))
    @textarea.val(text.replace(searchPhrase, "@#{@selectedUser.get('name')} ");)
    
    @deactivate()
    
  lookupMentions: ->
    text = @textarea.val()
    if text.indexOf("@") == -1
      @deactivate(clearMention: true)
      
    return unless @isActive()
    
    searchPhrase = text.slice(text.indexOf("@") + 1, _.getCaretPosition(@textarea))
    @renderUsers searchPhrase
    
  isActive: ->
    @$el.is(':visible')
  
  activate: ->
    return if @isActive()
    return if @textarea.val().match(/@/g).length > 1
    @$el.css('display', 'inline-block')
    
  deactivate: (options = {}) ->
    if options.clearMention
      @selectedUser = @collection.first()
      @headElement.find("#mentioned-user-id").val('')
      
    @$el.find('li').removeClass('selected')
    @$el.hide()
  
  _markSelected: (el) ->
    return if el.length == 0
    el.addClass('selected')
    @selectedUser = @collection.get el.data('user-id')
    
  _selectPrevious: ->
    prevUser = @$el.find("li[data-user-id=#{@selectedUser.get('id')}]").prev()
    @_markSelected(prevUser)
    
  _selectNext: ->
    nextUser = @$el.find("li[data-user-id=#{@selectedUser.get('id')}]").next()
    @_markSelected(nextUser)
