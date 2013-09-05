Task = require('models/task')
Tasks = require('collections/tasks')

describe 'Task', ->
  beforeEach ->
    @model = new Task(text: 'test')
    
  describe '#close', ->
    beforeEach ->
      spyOn($, 'ajax').andCallFake (options) ->
        options.success()
        
    it 'should be true after closing', ->
      @model.close()
      expect(@model.get('done')).toBeTruthy()
  
  
  describe '#isMy', ->
    beforeEach ->
      app.user.id = '123'
      @model = new Task(text: 'test', user_id: '123')
      @assigned = new Task(text: 'assigned to Tom', user_id: '234')
  
    it 'task should be my', ->
      expect(@model.isMy()).toBeTruthy()
      
    it 'task should not be my', ->
      expect(@assigned.isMy()).toBeFalsy()
  
  
  describe '#toggle', ->
    beforeEach ->
      spyOn($, 'ajax').andCallFake (options) ->
        options.success()
        
    it 'isDone should be true after the toggle', ->
      @model.toggle()
      expect(@model.get('done')).toBeTruthy()
    
    it 'isDone should be false after toggling twice', ->
      @model.toggle()
      @model.toggle()
      expect(@model.get('done')).toBeFalsy()
    
  describe '#validate', ->
    beforeEach ->
      @spy = jasmine.createSpy('-validator-')
      @model.on('error', @spy)

    it "should be valid without user", ->
      @model.set(user_id: null)
      @model.save()
      expect(@spy.calls.length).toEqual(0)
      
    it "should validate text presence", ->
      @model.set(text: '')
      expect(@spy.mostRecentCall.args[1]).toEqual(text : [ 'required' ] )
      
    it "should validate text length", ->
      @model.set(text: 'test test test test test test test test test test test test test test test test test test test test test test test test test test test test !')
      expect(@spy.mostRecentCall.args[1]).toEqual(text : [ 'maxlength' ] )


  describe 'urls', ->
    it 'has valid #paramRoot', ->
      expect(@model.paramRoot).toEqual 'task'

    it 'has valid #urlRoot', ->
      expect(@model.urlRoot).toEqual 'api/v1/tasks'
