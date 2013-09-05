RevenueStreams = require('collections/revenue_streams')

describe 'RevenueStreams collection', ->
  beforeEach ->
    @collection = new RevenueStreams()

  describe '#isUsed', ->
    beforeEach ->
      @collection.add [{name: 'First'}, {name: 'Second'}, {name: 'Third'}]

    it 'returns true when contains name',       -> expect(@collection.isUsed('Second')).toBeTruthy()
    it 'returns false when name does not exist', -> expect(@collection.isUsed('Anything')).toBeFalsy()