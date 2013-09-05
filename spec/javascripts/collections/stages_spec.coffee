Stages = require('collections/stages')

describe 'Stages collection', ->
  beforeEach ->
    @collection = new Stages [
      {id: 3, position: 2}
      {id: 5, position: 1}
      {id: 7, position: 8}
    ]

  describe 'position methods', ->
    it 'topline - returns stage with lowest position', ->
      expect(@collection.topline().id).toEqual 7

    it 'customer - returns stage with highest position', ->
      expect(@collection.customer().id).toEqual 5

    it 'notCustomerIds - returns all except customer stage', ->
      expect(@collection.notCustomerIds()).toEqual [3, 7]

    it 'notToplineIds - returns all except topline stage', ->
      expect(@collection.notToplineIds()).toEqual [5, 3]
