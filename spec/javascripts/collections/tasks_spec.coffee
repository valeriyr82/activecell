Tasks = require('collections/tasks')
Task = require('models/task')

describe 'Tasks', ->
  beforeEach ->
    @task1 = new Task
      id: 1
      text: "test 1"
      done: false
      created_at: moment().subtract('months', 2).toDate()
      
    @task2 = new Task
      id: 2
      text: "test 2"
      done: true
      created_at: moment().subtract('months', 1).toDate()
    
    @task3 = new Task
      id: 3
      text: "test 3"
      done: true
      created_at: moment().toDate()
      
    @collection = new Tasks()  
    @collection.add [@task1, @task2, @task3]


  describe 'tasks collection', ->
     it "should have task model", ->
      expect(@collection.length).toEqual 3
      expect(@collection.get(1).get('text')).toEqual 'test 1'


  describe '#comparator', ->
    it 'orders by status and created_at field', ->
      expect(@collection.pluck('id')).toEqual [1, 3, 2]

  describe '#my', ->
  
  describe '#done', ->
