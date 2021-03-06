#= require sprockets/commonjs
#= require jquery
#= require underscore
#= require backbone
#= require highcharts
#= require bootstrap
#
#  APPLICATION
#= require ./support/utils
#= require_tree ../templates/admin
#= require_tree ./admin/collections/shared
#= require_tree ./admin/collections
#= require_tree ./admin/views
#= require_self

Streams            = require('admin/collections/streams')
Segments           = require('admin/collections/segments')
Channels           = require('admin/collections/channels')
Stages             = require('admin/collections/stages')
Months             = require('admin/collections/months')
ChannelSegmentMix  = require('admin/collections/channel_segment_mix')
InitialVolume      = require('admin/collections/initial_volume')
ToplineGrowth      = require('admin/collections/topline_growth')
ConversionRates    = require('admin/collections/conversion_rates')
ChurnRates         = require('admin/collections/churn_rates')

ConversionForecast = require('admin/collections/conversion_forecast')
CustomerForecast   = require('admin/collections/customer_forecast')
ChurnForecast      = require('admin/collections/churn_forecast')

IndexView          = require('admin/views/index/index')
TestsView          = require('admin/views/tests/tests')
ScaffoldingView    = require('admin/views/style_guide/scaffolding')
BaseCSSView        = require('admin/views/style_guide/base_css')
ComponentsView     = require('admin/views/style_guide/components')
TablesView         = require('admin/views/style_guide/tables')
ChartsView         = require('admin/views/style_guide/charts')

window.admin =
  # Map for keys in schema
  # if you want to add new attribute, you should describe its here
  #
  # Returns array of models
  schemaMap: (key) ->
    switch key
      when 'stageId'         then admin.stages.models
      when 'channelId'       then admin.channels.models
      when 'segmentId'       then admin.segments.models
      when 'monthId'         then admin.months.models
      when 'notFirstStageId' then admin.stages.last(admin.stages.length - 1)

  inputs:
    streams: [
      {id: 2342, name: 'Revenue stream 1'}
      {id: 21231, name: 'Revenue stream 2'}
      {id: 123, name: 'Revenue stream 3'}
    ]
    segments: [
      {id: 7, name: 'Customer segment 1'}
      {id: 6, name: 'Customer segment 2'}
      {id: 2, name: 'Customer segment 3'}
    ]
    channels: [
      {id: 5, name: 'Channel 1'}
      {id: 2, name: 'Channel 2'}
      {id: 323, name: 'Channel 3'}
      {id: 4121, name: 'Channel 4'}
      {id: 54244, name: 'Channel 5'}
    ]
    stages: [
      {id: 10292, name: 'Stage 1 (Topline)', lag: 1, is_topline: true, is_customer: false}
      {id: 22394, name: 'Stage 2', lag: 0, is_topline: false, is_customer: false}
      {id: 32943, name: 'Stage 3 (Customer)', lag: '', is_topline: false, is_customer: true}
    ]
    months: [
      {id: 1 }, {id: 2 }, {id: 3 }, {id: 4 }, {id: 5 }, {id: 6 }, {id: 7 }, {id: 8 }, {id: 9 }
      {id: 10}, {id: 11}, {id: 12}, {id: 13}, {id: 14}, {id: 15}, {id: 16}, {id: 17}, {id: 18}
      {id: 19}, {id: 20}, {id: 21}, {id: 22}, {id: 23}, {id: 24}, {id: 25}, {id: 26}, {id: 27}
      {id: 28}, {id: 29}, {id: 30}, {id: 31}, {id: 32}, {id: 33}, {id: 34}, {id: 35}, {id: 36}
    ]
    # [channel_index][segment_index] is a percentage
    channelSegmentMix: [
      [100,0,0],
      [25,25,50],
      [0,100,0],
      [20,40,40],
      [30,5,65]
    ]
    # [stage_index][channel_index][segment_index] is an integer
    initialVolume: [
      [
        [4,14,15],
        [15,12,15],
        [14,11,16],
        [17,6,7],
        [8,10,5]
      ],
      [
        [8,17,17],
        [13,6,16],
        [9,7,19],
        [1,13,18],
        [15,4,15]
      ],
      [
        [2,6,3],
        [5,3,19],
        [3,9,20],
        [16,17,11],
        [8,14,4]
      ]
    ]
    # [channel_index][monthId] is an integer
    toplineGrowth: [
      [4,4,4,17,17,7,7,4,12,18,4,1,15,3,18,18,16,8,14,20,4,17,11,18,17,20,13,12,1,12,16,0,3,13,2,0]
      [7,18,20,7,4,18,0,20,1,5,2,4,8,7,9,0,5,16,12,12,20,9,18,16,10,16,12,7,20,18,6,2,4,5,8,17]
      [18,11,16,12,8,10,9,9,13,18,13,1,9,15,16,0,9,0,20,9,20,4,9,13,2,11,16,8,7,1,1,20,6,13,11,13]
      [9,2,8,18,20,2,2,17,4,18,5,13,19,10,4,7,5,12,2,9,15,17,3,9,19,11,16,0,1,12,0,12,1,14,2,2]
      [5,6,1,16,3,16,6,8,3,12,17,12,15,8,15,12,3,14,15,18,0,9,0,17,17,13,3,0,15,3,10,5,7,17,9,9]
    ]
    # [stage_index][channel_index][monthId] is a percentage
    conversionRates: [
      [
        [46,66,47,21,4,68,44,43,20,43,63,71,0,7,78,69,67,70,0,62,33,67,28,19,30,8,69,88,47,64,21,15,16,5,92,14]
        [70,17,38,25,17,9,79,23,56,82,10,64,62,84,69,98,90,56,17,59,14,59,88,52,100,15,2,79,60,1,84,87,39,81,21,27]
        [30,26,6,39,89,6,12,83,79,78,63,77,47,98,9,78,42,39,13,42,25,40,63,5,97,86,55,48,48,48,38,55,44,22,57,28]
        [27,69,81,57,0,22,66,12,40,24,69,42,28,18,37,54,4,1,16,91,5,63,44,33,28,33,73,88,72,43,54,26,50,90,40,4]
        [33,77,63,46,3,57,38,55,1,26,75,14,33,57,45,98,14,99,64,69,3,94,75,63,26,72,60,18,35,31,2,45,69,68,53,84]
      ],
      [
        [3,28,0,37,46,62,41,97,34,39,9,73,75,74,26,4,25,58,59,56,85,11,10,60,9,86,23,29,13,40,99,30,91,7,62,67]
        [13,1,41,87,37,64,93,36,33,27,45,91,88,47,76,52,27,6,66,31,38,100,44,86,38,77,13,67,33,43,83,22,52,11,13,88]
        [47,10,73,9,17,75,26,74,89,13,95,77,53,29,98,74,64,27,15,70,97,98,48,66,48,56,63,83,28,94,60,27,20,51,66,82]
        [89,1,99,24,25,52,94,61,37,86,38,70,98,13,47,41,73,50,75,48,78,73,77,74,93,5,34,16,14,86,70,67,87,65,96,93]
        [91,6,70,14,35,16,23,97,37,98,17,44,10,89,63,15,86,57,77,7,91,93,31,14,90,1,49,78,17,3,6,33,11,72,99,79]
      ]
    ]
    # [segment_index][monthId] is a percentage
    churnRates: [
      [100,76,64,87,83,16,35,38,41,80,86,66,36,11,61,42,58,28,58,82,64,73,24,23,66,97,43,40,39,100,79,96,85,71,15,47]
      [10,49,50,35,72,50,93,74,41,46,79,70,88,1,25,40,80,78,60,24,59,48,92,92,51,9,17,38,98,23,46,86,21,35,81,42]
      [71,38,95,0,84,58,47,70,48,33,100,35,58,40,53,42,74,18,49,81,94,84,82,44,22,17,24,55,32,32,89,83,46,79,71,46]
    ]

window.Admin =
  initialize: ->
    @initCollections()
    @initForecasts()
    @initView()

  # Initializes collections with raw of inputs and assigns them to admin
  initCollections: ->
    admin.streams            = new Streams()
    admin.segments           = new Segments()
    admin.channels           = new Channels()
    admin.stages             = new Stages()
    admin.months             = new Months()
    admin.channelSegmentMix  = new ChannelSegmentMix()
    admin.initialVolume      = new InitialVolume()
    admin.toplineGrowth      = new ToplineGrowth()
    admin.conversionRates    = new ConversionRates()
    admin.churnRates         = new ChurnRates()

  # Initializes forecasts, builds values and turns on triggers for changes
  initForecasts: ->
    admin.conversionForecast = new ConversionForecast()
    admin.customerForecast   = new CustomerForecast()
    admin.churnForecast      = new ChurnForecast()

    admin.conversionForecast.build()
    admin.conversionForecast.onTriggers()

    admin.customerForecast.onTriggers()
    admin.churnForecast.build()
    admin.churnForecast.onTriggers()

  initView: ->
    switch location.pathname
      when '/admin'                         then new IndexView().render()
      when '/admin/tests'                   then new TestsView()
      when '/admin/style_guide'             then new ScaffoldingView().render()
      when '/admin/style_guide/base_css'    then new BaseCSSView().render()
      when '/admin/style_guide/components'  then new ComponentsView().render()
      when '/admin/style_guide/scaffolding' then new ScaffoldingView().render()
      when '/admin/style_guide/tables'      then new TablesView().render()
      when '/admin/style_guide/charts'      then new ChartsView().render()
