BackgroundJob = require('models/company/background_job')

describe 'BackgroundJob', ->
  beforeEach ->
    @model = new BackgroundJob()

  describe '#url', ->
    describe 'without id', ->
      it 'should return path to the last job', ->
        expect(@model.url()).toEqual('/api/v1/background_jobs/last')

    describe 'with id', ->
      it 'should return path to the specific job', ->
        @model.id = 123
        expect(@model.url()).toEqual('/api/v1/background_jobs/123')

  describe '#canScheduleNextJob', ->
    describe 'when the job status is not defined', ->
      it 'should return true', ->
        expect(@model.canScheduleNextJob()).toBeTruthy()

    describe 'when the job is completed or failed', ->
      it 'should return true', ->
        @model.set(status: 'completed')
        expect(@model.canScheduleNextJob()).toBeTruthy()

        @model.set(status: 'failed')
        expect(@model.canScheduleNextJob()).toBeTruthy()

    describe 'when the job is queued or in progress', ->
      it 'should return false', ->
        @model.set(status: 'queued')
        expect(@model.canScheduleNextJob()).toBeFalsy()

        @model.set(status: 'working')
        expect(@model.canScheduleNextJob()).toBeFalsy()
