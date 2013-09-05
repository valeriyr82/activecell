Periods = require('collections/periods')

describe 'Periods collection', ->
  beforeEach ->
    @collection = new Periods()

  describe 'comparator', ->
    beforeEach ->
      @collection.add [
        {id: 1, first_day: '2011-12-01'},
        {id: 2, first_day: '2012-01-01'},
        {id: 3, first_day: '2010-08-01'}
      ]

    it 'orders periods ascending by first_day', ->
      expect(@collection.pluck 'id').toEqual [3, 1, 2]

  describe 'range', ->
    beforeEach ->
      stubCurrentDate '2012-06-01'
      @collection.add [
        {id: 1, first_day: '2010-07-01'}
        {id: 2, first_day: '2011-11-01'}
        {id: 3, first_day: '2012-04-01'}
        {id: 4, first_day: '2010-08-01'}
        {id: 5, first_day: '2012-06-01'}
        {id: 6, first_day: '2012-08-01'}
      ]

    it 'returns list of ids for selected period', ->
      expect(@collection.range -12, -1).toEqual [2, 3]

    it 'when parammeter is null ignores this condition', ->
      expect(@collection.range null, -1).toEqual [1, 4, 2, 3]
      expect(@collection.range 0, null).toEqual [5, 6]
