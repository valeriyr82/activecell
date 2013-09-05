Report = require('models/report')

describe 'Report model', ->
  describe 'initialize', ->
    it 'init @analyses collection', ->
      model = new Report id: 'new-report', status: 0, name: 'New report', \
                         analyses: [{type: 'balance_sheet'}, {type: 'breakeven'}, {type: 'burn_runway'}]

      expect(model.analyses.length).toEqual 3

  describe 'validate', ->
    it 'name can not be blank', ->
      model = new Report(id: '123')
      expect(model.isValid()).toBeFalsy()
