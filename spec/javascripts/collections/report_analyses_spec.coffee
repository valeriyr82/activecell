ReportAnalysis = require('collections/report_analyses')

describe 'ReportAnalysis collection', ->
  beforeEach ->
    @collection = new ReportAnalysis [
      {id: 1, type: 'balance_sheet', created_at: moment().add('months', 2).toDate()},
      {id: 2, type: 'balance_sheet', created_at: moment().toDate()},
      {id: 3, type: 'breakeven',     created_at: moment().add('months', 1).toDate()}
    ], 'new-report'

  describe 'initialize', ->
    it 'init @reportId', ->
      expect(@collection.reportId).toEqual 'new-report'

    describe 'comparator', ->
      it 'orders by created_at field', ->
        expect(@collection.pluck('id')).toEqual [2,3,1]
