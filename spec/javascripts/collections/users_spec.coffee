Users = require('collections/users')

describe 'Users collection', ->
  beforeEach ->
    @collection = new Users [
      {id: 1, name: 'John Blam'}
      {id: 2, name: 'Bob Jovi'}
      {id: 3, name: 'Tina Bowie'}
      {id: 4, name: 'Tina Murner'}
    ]

  describe '#searchByName', ->
    it 'returns only users with matching name', ->
      expect(@collection.searchByName('John').length).toEqual 1

    it 'returns more than one record if both match the search phase', ->
      expect(@collection.searchByName('Tina').length).toEqual 2
      
    it "returns empty collection if passphrase doesn't match anything", ->
      expect(@collection.searchByName('Nothing found man').length).toEqual 0
      
    it "returns collection if passphrase match the middle part of the name", ->
      expect(@collection.searchByName('ina').length).toEqual 2
      
    it "shouldn't be case sensitive", ->
      expect(@collection.searchByName('bob').length).toEqual 1
      
    it "should match by whole word only", ->
      expect(@collection.searchByName('jvi').length).toEqual 0
      
  describe '#without', ->
    it 'should return users with different id', ->
      @collection = new Users @collection.without(1)
      expect(@collection.length).toEqual 3
      expect(@collection.first().get('id')).toEqual 2
      
    it 'should return all users when none has given id', ->
      @collection = new Users @collection.without(1111)
      expect(@collection.length).toEqual 4