utils = require('analysis/shared/utils')

# Base class for analysis
module.exports = class BaseAnalysis
  # List of fields for group
  groupBy: ['period_id']

  # Add analyse to Backbone.Model
  #
  # method  - method name
  # options - specific for analysis options
  #
  # Returns object with method name
  @extend: (methodName, options) ->
    getAnalyse = =>
      options.default = false
      @["#{methodName}-#{options.name}"] ||= new @(options)

    _.object methodName, (range) ->
      analyse = getAnalyse()
      values  = analyse.get(@id)

      analyse.get range, @, (periodId) =>
        for option in ['actual', 'plan'] when options[option]
          value = options[option].call(@, periodId)
          value = _.object(option, value) unless _.isObject(value)
          analyse.set periodId, value, values

        analyse.set periodId, analyse.calc?.call(@, periodId), values if analyse.calc
        values[periodId]

  # Init @values and calls `initialize`
  # initialize - is a constructor for inherited analysis
  constructor: (options = {}) ->
    @_handleOptions(options)
    @values = @_initValues()
    @initialize?(options)
    @_runCalculations(options)

  # Convinient way to get access to @values
  #
  # range - array of period ids or singe periodId
  #
  # Examples:
  #
  #   @get('2012-02')
  #   # => 40
  #
  #   @get(['2012-01', '2012-02'])
  #   # => [{actual: 20, plan: 0}, {actual: 10, plan: 12}]
  #
  # Returns object or list of objects
  get: (range, context = @, getValue) ->
    getValue ||= (periodId) => @values[periodId]
    if _.isArray(range)
      result = {}
      for periodId in range
        result[periodId] = getValue.call(context, periodId)
      result
    else
      getValue.call(context, range)

  set: (periodId, value, values = @values) ->
    values[periodId] = utils.merge values[periodId], value

  setBackbone: (collection, conditions = null, mapped = null) ->
    @assign collection?.minify(), conditions: conditions, mapped: mapped, getValue: collection.getValue()

  # Assigns values from filtered collection to correct place in @values
  assign: (collection, options) ->
    items = collection
    items = utils.filter(items, options.conditions) if options.conditions
    items = utils.mapped(items, options.mapped, app[@_schema[options.mapped.from]]) if options.mapped

    for item in items
      value  = options.getValue(item) || {}
      values = @values
      values = values[item[key]] for key in @groupBy.slice(0, -1)
      utils.handle values[item[@groupBy.slice(-1)]], value if values

  idSchema: (schemaId) ->
    switch schemaId
      when 'stage_not_topline_id' then app.stages.notToplineIds()
      else app[@_schema[schemaId]].ids()

  #
  # PRIVATE
  #

  _schema:
    'period_id'   : 'periods'
    'channel_id'  : 'channels'
    'segment_id'  : 'segments'
    'customer_id' : 'customers'
    'stage_id'    : 'stages'

  _handleOptions: (options) ->
    @groupBy = _.uniq options.groupBy.concat(@groupBy) if _.isArray(options.groupBy)

  _initValues: (values = {}, level = 0) ->
    collectionIds = @idSchema(@groupBy[level])

    for itemId in collectionIds
      values[itemId] = {}
      if level isnt @groupBy.length - 1
        @_initValues values[itemId], level + 1
    values

  _runCalculations: (options) ->
    for method in ['default', 'actual', 'plan']
      @[method]?() if _.isUndefined(options[method])
