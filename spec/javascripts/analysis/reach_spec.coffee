Reach              = require('analysis/reach')
Periods            = require('collections/periods')
Channels           = require('collections/channels')
Stages             = require('collections/stages')
ConversionSummary  = require('collections/conversion_summary')
ConversionForecast = require('collections/conversion_forecast')

describe 'reach', ->
  beforeEach ->
    app.periods = new Periods [
      {id: 'last-month',    first_day: '2012-01-01'},
      {id: 'this-month',    first_day: '2012-02-01'},
      {id: 'next-month',    first_day: '2012-03-01'},
      {id: 'two-years-ago', first_day: '2010-02-14'}
    ]
    app.channels = new Channels [{id: 'channel1'}, {id: 'channel2'}]
    app.stages   = new Stages [{id: 'topline', position: 2}, {id: 'customer', position: 1}]
    app.conversionSummary  = new ConversionSummary [
      {period_id: 'last-month', stage_id: 'topline',  channel_id: 'channel1', customer_volume: 1},
      {period_id: 'last-month', stage_id: 'topline',  channel_id: 'channel2', customer_volume: 2},
      {period_id: 'this-month', stage_id: 'topline',  channel_id: 'channel1', customer_volume: 3},
      {period_id: 'this-month', stage_id: 'topline',  channel_id: 'channel2', customer_volume: 4},
      {period_id: 'this-month', stage_id: 'customer', channel_id: 'channel1', customer_volume: 5},
    ]
    app.conversionForecast = new ConversionForecast [
      {period_id: 'last-month', channel_id: 'channel1', stage_id: 'topline', conversion_forecast: 6},
      {period_id: 'last-month', channel_id: 'channel2', stage_id: 'topline', conversion_forecast: 7},
      {period_id: 'this-month', channel_id: 'channel1', stage_id: 'topline', conversion_forecast: 8},
      {period_id: 'this-month', channel_id: 'channel2', stage_id: 'topline', conversion_forecast: 9},
      {period_id: 'next-month', channel_id: 'channel1', stage_id: 'topline', conversion_forecast: 10},
      {period_id: 'next-month', channel_id: 'channel2', stage_id: 'topline', conversion_forecast: 11},
      {period_id: 'this-month', channel_id: 'channel1', stage_id: 'customer', conversion_forecast: 12},
    ]
    stubCurrentDate '2012-02-14'

  describe 'default reach', ->
    beforeEach ->
      @analysis = new Reach()

    describe 'get', ->
      it 'contains both channels', ->
        result = @analysis.get('this-month')
        expect(_.keys(result).length).toEqual 2

      it 'calculates values for a single period', ->
        result = @analysis.get('last-month')
        expect(result['channel1']).toEqual actual: 1, plan: 6
        expect(result['channel2']).toEqual actual: 2, plan: 7

      it 'contains no "actuals" for a future month', ->
        result = @analysis.get('next-month')
        expect(result['channel1']).toEqual plan: 10
        expect(result['channel2']).toEqual plan: 11

      it 'contains a hash grouped by channel', ->
        result = @analysis.get(['last-month', 'this-month', 'next-month'])['this-month']
        expect(result['channel1']).toEqual actual: 3, plan: 8
        expect(result['channel2']).toEqual actual: 4, plan: 9

  describe 'channel reach', ->
    beforeEach ->
      @channel = app.channels.get('channel1')

    describe 'get', ->
      it 'calculates values for a single period', ->
        expect(@channel.reach 'last-month').toEqual actual: 1, plan: 6

      it 'contains no "actuals" for a future month', ->
        expect(@channel.reach 'next-month').toEqual plan: 10

      it 'contains a hash', ->
        result = @channel.reach ['last-month', 'this-month', 'next-month']
        expect(result['this-month']).toEqual actual: 3, plan: 8
