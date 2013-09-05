RevenueStreams = require('collections/revenue_streams')

describe 'RevenueStream model', ->
  beforeEach ->
    @collection = new RevenueStreams([{name: 'test'}])
    @model = @collection.first()

  describe '#validate', ->
    beforeEach ->
      @spy = jasmine.createSpy('-validator-')
      @model.on('error', @spy)

    it "can't be blank", ->
      @model.set(name: '')
      expect(@spy.mostRecentCall.args[1]).toEqual(field: 'name', message: "Can't be blank")

    it "can't be exist", ->
      @model.set(name: 'test')
      expect(@spy.mostRecentCall.args[1]).toEqual(field: 'name', message: 'Name has already been taken')

    it 'returns null with valid attributes', ->
      @model.set(name: 'any')
      expect(@spy).wasNotCalled()