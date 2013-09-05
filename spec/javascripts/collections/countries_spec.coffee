Countries = require('collections/countries')

describe 'Countries', ->
  beforeEach ->
    @collection = new Countries [
      {id: 1, name: 'UNITED STATES'},
      {id: 2, name: 'MOROCCO'},
      {id: 3, name: 'PALAU'}
    ]

  it 'orders by name', ->
    expect(@collection.pluck('id')).toEqual [2, 3, 1]
