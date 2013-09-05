Reports = require('collections/reports')

describe 'Reports collection', ->
  describe 'dashboard', ->
    it 'creates new report if collection does not have dashboard', ->
      spyOn($, 'ajax')

      collection = new Reports []
      report     = collection.dashboard()

      expect(report.isValid()).toBeTruthy()
      expect(report.get 'report_type').toEqual 1
      expect(report.analyses.length).toEqual 0
      expect($.ajax).toHaveBeenCalled()